import 'dart:typed_data';
import '../../config/constants.dart';
import 'protobuf_utils.dart';
import 'tx_message.dart';

class MsgSend implements TxMessage {
  final String fromAddress;
  final String toAddress;
  final String denom;
  final String amount;

  MsgSend({
    required this.fromAddress,
    required this.toAddress,
    required this.denom,
    required this.amount,
  });

  @override
  String get typeUrl => GonkaConstants.msgSendTypeUrl;

  @override
  Uint8List encode() {
    final writer = ProtobufWriter();
    writer.writeString(1, fromAddress);
    writer.writeString(2, toAddress);
    writer.writeMessage(3, _encodeCoin());
    return writer.toBytes();
  }

  Uint8List _encodeCoin() {
    final writer = ProtobufWriter();
    writer.writeString(1, denom);
    writer.writeString(2, amount);
    return writer.toBytes();
  }
}
