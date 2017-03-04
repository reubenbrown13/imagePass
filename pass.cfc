/**
 * pass.cfc
 * This library takes a string and encodes it into an image.
 * There is also a function to compare 2 images to see if they are identical.
 *
 * @author Reuben Brown
 * @date 2017/03/03
 **/
component accessors=true output=false persistent=false {
  /**
  * Takes a string and converts it to either a list of base10 or base16 values.
  * Each item is delimited by \x.
  **/
  private function convertString(required string input = "", string base = "10") {
    var output = "";
    var ch = "";
    /* check for valid bases */
    if (arguments.base NEQ 10 AND arguments.base NEQ 16) {
      arguments.base = 10;
    }

    /* loop over string and convert each character to it's numeric/hex equivalent */
    for (i=1; i LT Len(arguments.input); i++){
      ch = Asc(Mid(arguments.input, i, 1));
      if (arguments.base EQ 16) {
        ch = uCase(formatBaseN(ch,"16"));
      }
      output = output & "\x" & ch;
    }
    return output;
  }

  /**
  * Take a string input and return a structure that describes a color unit.
  **/
  private function renderColorStruct(required string input = "") {
    var output = StructNew();
    var counter = 1;

    for (i=1; i LTE ListLen(arguments.input, '\x')-2; i=i+3){
      output[counter].r = ListGetAt(arguments.input, i, '\x');
      output[counter].b = ListGetAt(arguments.input, i+1, '\x');
      output[counter].g = ListGetAt(arguments.input, i+2, '\x');
      counter++;
    }

    return output;
  }

  /**
  * Renders an square image based on the provided color structure, size value, and multiplier.
  **/
  private function renderImage(required colorStruct = StructNew(), required numeric size = 8, numeric multiplier = 10) {
    var mult = arguments.multiplier;
    var dim = arguments.size*mult;
    var output = ImageNew("",dim,dim);
    var x = 0;
    var y = 0;
    for(i=1; i LTE StructCount(arguments.ColorStruct); i++) {
      x = ((i-1)*mult % dim);
      y = (floor((i-1)/arguments.size)*mult % dim);
      ImageSetDrawingColor(output, "#arguments.ColorStruct[i].r#,#arguments.ColorStruct[i].b#,#arguments.ColorStruct[i].g#");
      ImageDrawRect(output, x, y, mult, mult, true);
    }
    return output;
  }

  /**
  * Takes a string and salt and encodes it into an image.
  **/
  remote function encString(required string input = "", string salt = ""){
    var size = floor(sqr(Len(arguments.input)+Len(arguments.salt)));
    var output = convertString(ToBase64(arguments.input&arguments.salt, "utf-16"));
    output = renderColorStruct(output, 10);
    output = renderImage(output, size, 10);
    return output;
  }

  /**
  * Compares 2 images to see if they match to determine if the password provided is correct.
  **/
  remote boolean function testPass(required input1, required input2){
    var output = false;

    if (arguments.input1.height EQ arguments.input2.height AND arguments.input1.width EQ arguments.input2.width) {
      if (toString(ImageGetBlob(arguments.input1)) EQ toString(ImageGetBlob(arguments.input2))) {
        output = true;
      }
    }

    return output;
  }
}
