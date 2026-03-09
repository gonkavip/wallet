import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gonka_wallet/core/transaction/protobuf_utils.dart';
import 'package:gonka_wallet/core/transaction/msg_send.dart';
import 'package:gonka_wallet/core/transaction/tx_builder.dart';
import 'package:gonka_wallet/core/crypto/mnemonic_service.dart';
import 'package:gonka_wallet/core/crypto/hd_key_service.dart';

void main() {
  group('ProtobufWriter', () {
    test('encodes varint correctly', () {
      final writer = ProtobufWriter();
      writer.writeVarint(1, 150);
      final bytes = writer.toBytes();
      expect(bytes, [0x08, 0x96, 0x01]);
    });

    test('encodes string correctly', () {
      final writer = ProtobufWriter();
      writer.writeString(1, 'abc');
      final bytes = writer.toBytes();
      expect(bytes, [0x0A, 0x03, 0x61, 0x62, 0x63]);
    });

    test('encodes nested message', () {
      final inner = ProtobufWriter();
      inner.writeVarint(1, 1);
      final innerBytes = inner.toBytes();

      final outer = ProtobufWriter();
      outer.writeMessage(1, innerBytes);
      final bytes = outer.toBytes();

      expect(bytes, [0x0A, 0x02, 0x08, 0x01]);
    });
  });

  group('MsgSend', () {
    test('encodes correctly', () {
      final msg = MsgSend(
        fromAddress: 'gonka1abc',
        toAddress: 'gonka1def',
        denom: 'ngonka',
        amount: '1000000000',
      );
      final bytes = msg.encode();
      expect(bytes.isNotEmpty, true);

      final reader = ProtobufReader(bytes);
      final fields = <int, dynamic>{};
      while (reader.hasMore) {
        final (fieldNumber, wireType) = reader.readTag();
        if (wireType == 2) {
          fields[fieldNumber] = reader.readBytes();
        } else {
          reader.skip(wireType);
        }
      }
      expect(fields.containsKey(1), true);
      expect(fields.containsKey(2), true);
      expect(fields.containsKey(3), true);

      expect(utf8.decode(fields[1]), 'gonka1abc');
      expect(utf8.decode(fields[2]), 'gonka1def');
    });
  });

  group('TxBuilder', () {
    test('builds and signs a transaction', () {
      final mnemonic = MnemonicService.generate();
      final privKey = HDKeyService.derivePrivateKey(mnemonic);
      final pubKey = HDKeyService.derivePublicKey(mnemonic);

      final msg = MsgSend(
        fromAddress: 'gonka1sender',
        toAddress: 'gonka1receiver',
        denom: 'ngonka',
        amount: '1000000000',
      );

      final txBase64 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: pubKey,
        privateKey: privKey,
        accountNumber: 42,
        sequence: 7,
      );

      final decoded = base64Decode(txBase64);
      expect(decoded.isNotEmpty, true);

      final reader = ProtobufReader(decoded);
      final fieldNumbers = <int>[];
      while (reader.hasMore) {
        final (fieldNumber, wireType) = reader.readTag();
        fieldNumbers.add(fieldNumber);
        reader.skip(wireType);
      }
      expect(fieldNumbers.contains(1), true);
      expect(fieldNumbers.contains(2), true);
      expect(fieldNumbers.contains(3), true);

      HDKeyService.zeroKey(privKey);
    });

    test('same inputs produce same transaction', () {
      final mnemonic = MnemonicService.generate();
      final privKey = HDKeyService.derivePrivateKey(mnemonic);
      final pubKey = HDKeyService.derivePublicKey(mnemonic);

      final msg = MsgSend(
        fromAddress: 'gonka1sender',
        toAddress: 'gonka1receiver',
        denom: 'ngonka',
        amount: '1000000000',
      );

      final tx1 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: pubKey,
        privateKey: privKey,
        accountNumber: 1,
        sequence: 0,
      );

      final tx2 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: pubKey,
        privateKey: privKey,
        accountNumber: 1,
        sequence: 0,
      );

      expect(tx1, tx2);
      HDKeyService.zeroKey(privKey);
    });
  });
}
