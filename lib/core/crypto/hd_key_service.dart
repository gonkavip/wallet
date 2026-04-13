import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import '../../config/constants.dart';
import 'address_service.dart';
import 'mnemonic_service.dart';

final _privateKeyHexRegex = RegExp(r'^[0-9a-f]{64}$');

String normalizePrivateKeyHex(String hex) {
  final cleaned =
      hex.trim().toLowerCase().replaceFirst(RegExp(r'^0x'), '');
  if (!_privateKeyHexRegex.hasMatch(cleaned)) {
    throw const FormatException('Invalid private key hex');
  }
  return cleaned;
}

class HDKeyService {
  static Uint8List derivePrivateKey(String mnemonic) {
    final seed = MnemonicService.toSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(Uint8List.fromList(seed));
    final child = root.derivePath(GonkaConstants.hdPath);
    return child.privateKey!;
  }

  static Uint8List derivePublicKey(String mnemonic) {
    final seed = MnemonicService.toSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(Uint8List.fromList(seed));
    final child = root.derivePath(GonkaConstants.hdPath);
    return child.publicKey;
  }

  static Uint8List publicKeyFromPrivate(Uint8List privateKey) {
    final node = bip32.BIP32.fromPrivateKey(privateKey, Uint8List(32));
    return node.publicKey;
  }

  static String addressFromPrivateKeyHex(String hex) {
    final cleaned = normalizePrivateKeyHex(hex);
    final bytes = Uint8List.fromList(HEX.decode(cleaned));
    final pubKey = publicKeyFromPrivate(bytes);
    return AddressService.fromPublicKey(pubKey);
  }

  static void zeroKey(Uint8List key) {
    for (var i = 0; i < key.length; i++) {
      key[i] = 0;
    }
  }
}
