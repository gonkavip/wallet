import 'dart:typed_data';
import '../../config/constants.dart';
import '../transaction/protobuf_utils.dart';
import 'msg_send_decoder.dart';

class WcMessageDescription {
  final String typeUrl;
  final bool isKnown;
  final MsgSendDecoded? msgSend;
  final String rawValueHex;

  const WcMessageDescription({
    required this.typeUrl,
    required this.isKnown,
    required this.rawValueHex,
    this.msgSend,
  });
}

class TxBodyDecoded {
  final List<WcMessageDescription> messages;
  final String memo;
  const TxBodyDecoded({required this.messages, required this.memo});

  bool get hasUnknownMessages => messages.any((m) => !m.isKnown);
}

class TxBodyDecoder {
  static TxBodyDecoded decode(Uint8List bodyBytes) {
    final reader = ProtobufReader(bodyBytes);
    final messages = <WcMessageDescription>[];
    String memo = '';

    while (reader.hasMore) {
      final (fieldNumber, wireType) = reader.readTag();
      switch (fieldNumber) {
        case 1:
          if (wireType != 2) {
            reader.skip(wireType);
            break;
          }
          final anyBytes = reader.readBytes();
          messages.add(_decodeAny(anyBytes));
        case 2:
          if (wireType != 2) {
            reader.skip(wireType);
            break;
          }
          memo = reader.readString();
        default:
          reader.skip(wireType);
      }
    }

    return TxBodyDecoded(messages: messages, memo: memo);
  }

  static WcMessageDescription _decodeAny(Uint8List anyBytes) {
    final reader = ProtobufReader(anyBytes);
    String typeUrl = '';
    Uint8List value = Uint8List(0);

    while (reader.hasMore) {
      final (fieldNumber, wireType) = reader.readTag();
      switch (fieldNumber) {
        case 1:
          if (wireType == 2) {
            typeUrl = reader.readString();
          } else {
            reader.skip(wireType);
          }
        case 2:
          if (wireType == 2) {
            value = reader.readBytes();
          } else {
            reader.skip(wireType);
          }
        default:
          reader.skip(wireType);
      }
    }

    MsgSendDecoded? msgSend;
    bool isKnown = false;
    if (typeUrl == GonkaConstants.msgSendTypeUrl) {
      msgSend = MsgSendDecoder.tryDecode(value);
      isKnown = msgSend != null;
    }

    return WcMessageDescription(
      typeUrl: typeUrl,
      isKnown: isKnown,
      msgSend: msgSend,
      rawValueHex: _hex(value),
    );
  }

  static String _hex(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
