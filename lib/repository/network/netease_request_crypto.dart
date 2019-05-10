import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:convert';

import 'package:encrypt/encrypt.dart';

const _keys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

const _publicKey =
    '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';

const _presetKey = '0CoJUm6Qyw8W8jud';
const _linuxApiKey = 'rFgB&h#%2?^eDg:Q';

final IV _iv = IV.fromUtf8("0102030405060708");

Map weApi(Map obj) {
  final text = json.encode(obj);
  final secKey = _createdSecretKey();
  final mode = AESMode.cbc;
  return {
    "params": _aesEncrypt(
            _aesEncrypt(text, mode, _presetKey, _iv).base64, mode, secKey, _iv)
        .base64,
    "encSecKey": _rsaEncrypt(_reverse(secKey), _publicKey).base16
  };
}

Map linuxApi(Map obj) {
  final text = json.encode(obj);
  return {
    "eparams":
        _aesEncrypt(text, AESMode.ecb, _linuxApiKey, null).base16.toUpperCase()
  };
}

String _createdSecretKey({int size = 16}) {
  StringBuffer buffer = StringBuffer();
  for (var i = 0; i < size; i++) {
    final position = math.Random().nextInt(_keys.length);
    buffer.write(_keys[position]);
  }
  return buffer.toString();
}

Encrypted _aesEncrypt(String text, AESMode mode, String key, IV iv) {
  final encrypt =
      Encrypter(AES(Key.fromUtf8(key), mode: mode, padding: "PKCS7"));
  return encrypt.encrypt(text, iv: iv);
}

Encrypted _rsaEncrypt(String text, String key) {
  final encrypt = Encrypter(RSA(publicKey: RSAKeyParser().parse(key)));

  final Uint8List buffer = Uint8List(128);
  List.copyRange(buffer, 0, Uint8List.fromList(utf8.encode(text)));
  return encrypt.algo.encrypt(Uint8List.fromList(utf8.encode(text)));
}

String _reverse(String content) {
  StringBuffer buffer = new StringBuffer();
  for (int i = content.length - 1; i >= 0; i--) {
    buffer.write(content[i]);
  }
  return buffer.toString();
}
