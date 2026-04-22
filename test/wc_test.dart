import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:gonka_wallet/config/constants.dart';
import 'package:gonka_wallet/core/transaction/msg_send.dart';
import 'package:gonka_wallet/core/transaction/protobuf_utils.dart';
import 'package:gonka_wallet/core/transaction/tx_builder.dart';
import 'package:gonka_wallet/core/walletconnect/msg_send_decoder.dart';
import 'package:gonka_wallet/core/walletconnect/sign_direct_decoder.dart';
import 'package:gonka_wallet/core/walletconnect/tx_body_decoder.dart';
import 'package:gonka_wallet/core/walletconnect/wc_uri_parser.dart';

void main() {
  group('WcUriParser', () {
    test('parses valid wc v2 URI', () {
      final uri =
          'wc:abc@2?relay-protocol=irn&symKey=aa&expiryTimestamp=9999999999';
      final parsed = WcUriParser.parse(uri);
      expect(parsed, isNotNull);
      expect(parsed!.topic, 'abc');
      expect(parsed.version, '2');
      expect(parsed.relayProtocol, 'irn');
      expect(parsed.isExpired, false);
    });

    test('flags expired URI', () {
      final uri = 'wc:t@2?relay-protocol=irn&symKey=x&expiryTimestamp=1';
      final parsed = WcUriParser.parse(uri);
      expect(parsed!.isExpired, true);
    });

    test('rejects v1 URI', () {
      expect(WcUriParser.parse('wc:abc@1?relay-protocol=irn'), isNull);
    });

    test('rejects malformed URI', () {
      expect(WcUriParser.parse('not a uri'), isNull);
      expect(WcUriParser.parse('wc:'), isNull);
      expect(WcUriParser.parse('wc:abc'), isNull);
    });

    test('extracts from deep link', () {
      final inner =
          'wc:abc@2?relay-protocol=irn&symKey=aa&expiryTimestamp=9999999999';
      final wrapped = 'gonka://wc?uri=${Uri.encodeComponent(inner)}';
      expect(WcUriParser.extractFromString(wrapped), inner);
    });

    test('extracts raw wc URI passthrough', () {
      const raw = 'wc:abc@2?relay-protocol=irn';
      expect(WcUriParser.extractFromString(raw), raw);
    });
  });

  group('MsgSendDecoder', () {
    test('round-trips through MsgSend.encode', () {
      final msg = MsgSend(
        fromAddress: 'gonka1from000000000000000000000000000000000',
        toAddress: 'gonka1to00000000000000000000000000000000000',
        denom: 'ngonka',
        amount: '1000000000',
      );
      final decoded = MsgSendDecoder.tryDecode(msg.encode());
      expect(decoded, isNotNull);
      expect(decoded!.fromAddress, msg.fromAddress);
      expect(decoded.toAddress, msg.toAddress);
      expect(decoded.amount, hasLength(1));
      expect(decoded.amount.first.denom, 'ngonka');
      expect(decoded.amount.first.amount, '1000000000');
    });

    test('returns null for unrelated bytes', () {
      expect(MsgSendDecoder.tryDecode(Uint8List.fromList([0, 1, 2, 3])),
          isNull);
    });
  });

  group('TxBodyDecoder', () {
    test('decodes body with one MsgSend and memo', () {
      final msg = MsgSend(
        fromAddress: 'gonka1from',
        toAddress: 'gonka1to',
        denom: 'ngonka',
        amount: '42',
      );
      final anyMsg = ProtobufWriter()
        ..writeString(1, msg.typeUrl)
        ..writeBytes(2, msg.encode());
      final body = ProtobufWriter()
        ..writeMessage(1, anyMsg.toBytes())
        ..writeString(2, 'hello');

      final decoded = TxBodyDecoder.decode(body.toBytes());
      expect(decoded.messages, hasLength(1));
      expect(decoded.messages.first.isKnown, true);
      expect(decoded.messages.first.msgSend!.fromAddress, 'gonka1from');
      expect(decoded.memo, 'hello');
      expect(decoded.hasUnknownMessages, false);
    });

    test('flags unknown message types', () {
      final anyMsg = ProtobufWriter()
        ..writeString(1, '/unknown.Msg')
        ..writeBytes(2, Uint8List.fromList([1, 2, 3]));
      final body = ProtobufWriter()..writeMessage(1, anyMsg.toBytes());
      final decoded = TxBodyDecoder.decode(body.toBytes());
      expect(decoded.messages.first.isKnown, false);
      expect(decoded.hasUnknownMessages, true);
    });
  });

  group('SignDirectDecoder', () {
    test('parses params with base64 bytes', () {
      final params = {
        'signerAddress': 'gonka1signer',
        'signDoc': {
          'bodyBytes': 'AQID',
          'authInfoBytes': 'BAUG',
          'chainId': 'gonka-mainnet',
          'accountNumber': '7',
        },
      };
      final payload = SignDirectDecoder.parse(params);
      expect(payload.signerAddress, 'gonka1signer');
      expect(payload.bodyBytes, [1, 2, 3]);
      expect(payload.authInfoBytes, [4, 5, 6]);
      expect(payload.chainId, GonkaConstants.chainId);
      expect(payload.accountNumber, 7);
    });

    test('builds result with correct structure', () {
      final payload = SignDirectDecoder.parse({
        'signerAddress': 'x',
        'signDoc': {
          'bodyBytes': '',
          'authInfoBytes': '',
          'chainId': 'c',
          'accountNumber': '0',
        },
      });
      final result = SignDirectDecoder.buildResult(
        payload: payload,
        signature: Uint8List(64),
        publicKey: Uint8List.fromList(List.filled(33, 0x02)),
      );
      expect(result['signature'], isMap);
      expect(result['signature']['pub_key']['type'],
          'tendermint/PubKeySecp256k1');
      expect(result['signed']['chainId'], 'c');
      expect(result['signed']['accountNumber'], '0');
    });
  });

  group('TxBuilder.signDirectFromBytes', () {
    test('is deterministic with the same inputs', () {
      final priv = Uint8List.fromList(List.filled(32, 0x11));
      final bodyBytes = Uint8List.fromList(List.generate(10, (i) => i));
      final authInfoBytes =
          Uint8List.fromList(List.generate(10, (i) => i + 10));

      final s1 = TxBuilder.signDirectFromBytes(
        bodyBytes: bodyBytes,
        authInfoBytes: authInfoBytes,
        chainId: 'gonka-mainnet',
        accountNumber: 5,
        privateKey: priv,
      );
      final s2 = TxBuilder.signDirectFromBytes(
        bodyBytes: bodyBytes,
        authInfoBytes: authInfoBytes,
        chainId: 'gonka-mainnet',
        accountNumber: 5,
        privateKey: priv,
      );
      expect(s1.length, 64);
      expect(s1, s2);
    });
  });
}
