import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class TxSigner {
  static Uint8List sign(Uint8List hash, Uint8List privateKey) {
    final params = ECDomainParameters('secp256k1');
    final signer = ECDSASigner(null, HMac(SHA256Digest(), 64));

    final privKeyParam = ECPrivateKey(
      _bytesToBigInt(privateKey),
      params,
    );

    signer.init(true, PrivateKeyParameter<ECPrivateKey>(privKeyParam));
    final signature = signer.generateSignature(hash) as ECSignature;

    final halfOrder = params.n >> 1;
    var s = signature.s;
    if (s > halfOrder) {
      s = params.n - s;
    }

    final r = _bigIntToBytes(signature.r, 32);
    final sBytes = _bigIntToBytes(s, 32);

    final result = Uint8List(64);
    result.setRange(0, 32, r);
    result.setRange(32, 64, sBytes);
    return result;
  }

  static Uint8List sha256Hash(Uint8List data) {
    final digest = SHA256Digest();
    return digest.process(data);
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final result = Uint8List(length);
    var v = value;
    for (var i = length - 1; i >= 0; i--) {
      result[i] = (v & BigInt.from(0xff)).toInt();
      v = v >> 8;
    }
    return result;
  }
}
