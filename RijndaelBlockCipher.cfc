/**
 * RijndaelBlockCipher.cfc
 * The doEncrypt and doDecrypt functions are publically visible, but not the function that creates the rijndael cipher. The encryption and decryption functions take a string, key and ivSalt returning an encrypted or decrypted string respectively.
 * 
 * The createRijndaelBlockCipher takes a key, ivSalt, a boolean to state whether the cipher will be used to encrypt or decrypt and the block size, although the block size is defaulted to 256 bits. The function is fairly well commented so it should make sense.
 *
 * The UDF at the bottom (special thanks to Jason Delmore for that nugget) ensures that ColdFusion correctly creates a byte array for the decryption. Some other ways of creating byte arrays just don't work or end up with inconsistent results in decryption or throw pad buffer corrupt errors.
 *
 * That's about it really. It took far too much effort, when the standard AES encryption uses 128bit blocks and 128 Bit Keys are for classified up to SECRET, 192-bit or higher for TOP-SECRET. 256bit blocks and 256bit keys are just a bit over the top. Just because you can doesn't mean you should.
 *
 * Please do remember that MCRYPT_RIJNDAEL_256 is the block size and not the encryption level. The encryption level is set by the strength of key that you pass into mcrypt_encrypt and increasing the block size does not increase the encryption strength.
 * @author Stephen-moretti (http://stackoverflow.com/users/164743/stephen-moretti)
 * @source http://tickanswer.com/solved/658081079/php-encryption-code-converted-to-coldfusion
 **/
component accessors=true output=false persistent=false {
  private function createRijndaelBlockCipher(required string key, required string ivSalt, boolean bEncrypt = 1, numeric blocksize = 256){
    // Create a block cipher for Rijndael
    var cryptEngine = createObject("java", "org.bouncycastle.crypto.engines.RijndaelEngine").init(arguments.blocksize);

    // Create a Block Cipher in CBC mode
    var blockCipher = createObject("java", "org.bouncycastle.crypto.modes.CBCBlockCipher").init(cryptEngine);

    // Create Padding - Zero Byte Padding is apparently PHP compatible.
    var zbPadding = CreateObject('java', 'org.bouncycastle.crypto.paddings.ZeroBytePadding').init();

    // Create a JCE Cipher from the Block Cipher
    var cipher = createObject("java", "org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher").init(blockCipher,zbPadding);

    // Create the key params for the cipher
    var binkey = binarydecode(arguments.key,"hex");
    var keyParams = createObject("java", "org.bouncycastle.crypto.params.KeyParameter").init(BinKey);

    var binIVSalt = Binarydecode(ivSalt,"hex");
    var ivParams = createObject("java", "org.bouncycastle.crypto.params.ParametersWithIV").init(keyParams, binIVSalt);

    cipher.init(javaCast("boolean",arguments.bEncrypt),ivParams);

    return cipher;
  }
  
  public function doEncrypt(required string message, required string key, required string ivSalt){
    var cipher = createRijndaelBlockCipher(key=arguments.key,ivSalt=arguments.ivSalt);
    var byteMessage = arguments.message.getBytes();
    var outArray = getByteArray(cipher.getOutputSize(arrayLen(byteMessage)));
    var bufferLength = cipher.processBytes(byteMessage, 0, arrayLen(byteMessage), outArray, 0);
    var cipherText = cipher.doFinal(outArray,bufferLength);

    return toBase64(outArray);
  }
  
  public function doDecrypt(required string message, required string key, required string ivSalt){
    var cipher = createRijndaelBlockCipher(key=arguments.key,ivSalt=arguments.ivSalt,bEncrypt=false);
    var byteMessage = toBinary(arguments.message);
    var outArray = getByteArray(cipher.getOutputSize(arrayLen(byteMessage)));
    var bufferLength = cipher.processBytes(byteMessage, 0, arrayLen(byteMessage), outArray, 0);
    var originalText = cipher.doFinal(outArray,bufferLength);

    return createObject("java", "java.lang.String").init(outArray);
  }
  
  function getByteArray(someLength) {
    byteClass = createObject("java", "java.lang.Byte").TYPE;
    return createObject("java","java.lang.reflect.Array").newInstance(byteClass, someLength);
  }
}
