<cfscript>
WriteOutput("Testing String Encoding.<br />");
passCfc = new pass();
testString = "NewPass";
salt = "TestSaltString";

output = passCfc.encString(testString, salt);
testInput = passCfc.encString(testString, salt);

ImageWrite(output, "ram:///output.png");
output = ImageRead("ram:///output.png");

ImageWrite(testInput, "ram:///testInput.png");
testInput = ImageRead("ram:///testInput.png");

WriteDump(passCfc.testPass(output, testInput));
</cfscript>
