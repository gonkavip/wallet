import 'package:flutter_test/flutter_test.dart';
import 'package:gonka_wallet/core/crypto/mnemonic_service.dart';
import 'package:gonka_wallet/core/crypto/hd_key_service.dart';
import 'package:gonka_wallet/core/crypto/address_service.dart';
import 'package:gonka_wallet/core/crypto/tx_signer.dart';
import 'package:gonka_wallet/config/constants.dart';
import 'dart:typed_data';

void main() {
  group('MnemonicService', () {
    test('generates valid 24-word mnemonic', () {
      final mnemonic = MnemonicService.generate();
      final words = mnemonic.split(' ');
      expect(words.length, 24);
      expect(MnemonicService.validate(mnemonic), true);
    });

    test('validates correct mnemonic', () {
      final mnemonic = MnemonicService.generate();
      expect(MnemonicService.validate(mnemonic), true);
    });

    test('rejects invalid mnemonic', () {
      expect(MnemonicService.validate('invalid words here'), false);
      expect(MnemonicService.validate(''), false);
    });

    test('generates seed from mnemonic', () {
      final mnemonic = MnemonicService.generate();
      final seed = MnemonicService.toSeed(mnemonic);
      expect(seed.length, 64);
    });
  });

  group('HDKeyService', () {
    late String mnemonic;

    setUp(() {
      mnemonic = MnemonicService.generate();
    });

    test('derives 32-byte private key', () {
      final key = HDKeyService.derivePrivateKey(mnemonic);
      expect(key.length, 32);
    });

    test('derives 33-byte compressed public key', () {
      final key = HDKeyService.derivePublicKey(mnemonic);
      expect(key.length, 33);
      expect(key[0] == 0x02 || key[0] == 0x03, true);
    });

    test('same mnemonic produces same keys', () {
      final priv1 = HDKeyService.derivePrivateKey(mnemonic);
      final priv2 = HDKeyService.derivePrivateKey(mnemonic);
      expect(priv1, priv2);

      final pub1 = HDKeyService.derivePublicKey(mnemonic);
      final pub2 = HDKeyService.derivePublicKey(mnemonic);
      expect(pub1, pub2);
    });

    test('zeroKey clears key bytes', () {
      final key = HDKeyService.derivePrivateKey(mnemonic);
      HDKeyService.zeroKey(key);
      expect(key.every((b) => b == 0), true);
    });
  });

  group('AddressService', () {
    test('generates gonka1... address from mnemonic', () {
      final mnemonic = MnemonicService.generate();
      final address = AddressService.fromMnemonic(mnemonic);
      expect(address.startsWith('gonka1'), true);
      expect(address.length, greaterThan(30));
    });

    test('same mnemonic produces same address', () {
      final mnemonic = MnemonicService.generate();
      final addr1 = AddressService.fromMnemonic(mnemonic);
      final addr2 = AddressService.fromMnemonic(mnemonic);
      expect(addr1, addr2);
    });

    test('validates correct gonka address', () {
      final mnemonic = MnemonicService.generate();
      final address = AddressService.fromMnemonic(mnemonic);
      expect(AddressService.validate(address), true);
    });

    test('rejects invalid addresses', () {
      expect(AddressService.validate(''), false);
      expect(AddressService.validate('cosmos1abc'), false);
      expect(AddressService.validate('gonka1invalid'), false);
    });

    test('different mnemonics produce different addresses', () {
      final addr1 = AddressService.fromMnemonic(MnemonicService.generate());
      final addr2 = AddressService.fromMnemonic(MnemonicService.generate());
      expect(addr1, isNot(addr2));
    });
  });

  group('TxSigner', () {
    test('sha256 produces 32-byte hash', () {
      final data = Uint8List.fromList([1, 2, 3, 4]);
      final hash = TxSigner.sha256Hash(data);
      expect(hash.length, 32);
    });

    test('signs and produces 64-byte signature', () {
      final mnemonic = MnemonicService.generate();
      final privKey = HDKeyService.derivePrivateKey(mnemonic);
      final message = Uint8List.fromList([1, 2, 3, 4, 5]);
      final hash = TxSigner.sha256Hash(message);
      final signature = TxSigner.sign(hash, privKey);
      expect(signature.length, 64);
    });

    test('deterministic signing', () {
      final mnemonic = MnemonicService.generate();
      final privKey = HDKeyService.derivePrivateKey(mnemonic);
      final message = Uint8List.fromList([1, 2, 3, 4, 5]);
      final hash = TxSigner.sha256Hash(message);
      final sig1 = TxSigner.sign(hash, privKey);
      final sig2 = TxSigner.sign(hash, privKey);
      expect(sig1, sig2);
    });
  });

  group('Constants', () {
    test('denomMultiplier is 10^9', () {
      expect(denomMultiplier, BigInt.from(1000000000));
    });

    test('formatGnk formats correctly', () {
      expect(formatGnk(BigInt.from(1000000000)), '1');
      expect(formatGnk(BigInt.from(1500000000)), '1.50');
      expect(formatGnk(BigInt.from(1230000000)), '1.23');
      expect(formatGnk(BigInt.parse('1463293560000000')),
          '1,463,293.56');
      expect(formatGnk(BigInt.from(0)), '0');
      expect(formatGnk(BigInt.from(123456789)), '0.12');
      expect(formatGnk(BigInt.from(120000)), '0.00012');
      expect(formatGnk(BigInt.from(1000000)), '0.001');
    });

    test('parseGnk parses correctly', () {
      expect(parseGnk('1'), BigInt.from(1000000000));
      expect(parseGnk('1.5'), BigInt.from(1500000000));
      expect(parseGnk('0'), BigInt.zero);
      expect(parseGnk('0.123456789'), BigInt.from(123456789));
    });

    test('format/parse roundtrip', () {
      final values = [
        BigInt.from(0),
        BigInt.from(1000000000),
        BigInt.from(1230000000),
      ];
      for (final v in values) {
        expect(parseGnk(formatGnk(v)), v);
      }
    });
  });
}
