import 'dart:typed_data';
import '../../config/constants.dart';
import 'protobuf_utils.dart';
import 'tx_message.dart';

class MsgUnjail implements TxMessage {
  final String validatorAddr;

  MsgUnjail({required this.validatorAddr});

  @override
  String get typeUrl => GonkaConstants.msgUnjailTypeUrl;

  @override
  Uint8List encode() {
    final writer = ProtobufWriter();
    writer.writeString(1, validatorAddr);
    return writer.toBytes();
  }
}
