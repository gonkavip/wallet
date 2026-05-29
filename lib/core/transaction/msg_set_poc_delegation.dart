import 'dart:typed_data';
import '../../config/constants.dart';
import 'protobuf_utils.dart';
import 'tx_message.dart';

class MsgSetPocDelegation implements TxMessage {
  final String sender;
  final String modelId;

  final String delegateTo;

  MsgSetPocDelegation({
    required this.sender,
    required this.modelId,
    required this.delegateTo,
  });

  @override
  String get typeUrl => GonkaConstants.msgSetPocDelegationTypeUrl;

  @override
  Uint8List encode() {
    final writer = ProtobufWriter();
    writer.writeString(1, sender);
    writer.writeString(2, modelId);

    if (delegateTo.isNotEmpty) {
      writer.writeString(3, delegateTo);
    }
    return writer.toBytes();
  }
}
