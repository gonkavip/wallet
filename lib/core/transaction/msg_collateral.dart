import 'dart:typed_data';
import '../../config/constants.dart';
import 'protobuf_utils.dart';
import 'tx_message.dart';

class MsgDepositCollateral implements TxMessage {
  final String participant;
  final String denom;
  final String amount;

  MsgDepositCollateral({
    required this.participant,
    required this.denom,
    required this.amount,
  });

  @override
  String get typeUrl => GonkaConstants.msgDepositCollateralTypeUrl;

  @override
  Uint8List encode() {
    final writer = ProtobufWriter();
    writer.writeString(1, participant);
    writer.writeMessage(2, _encodeCoin());
    return writer.toBytes();
  }

  Uint8List _encodeCoin() {
    final writer = ProtobufWriter();
    writer.writeString(1, denom);
    writer.writeString(2, amount);
    return writer.toBytes();
  }
}

class MsgWithdrawCollateral implements TxMessage {
  final String participant;
  final String denom;
  final String amount;

  MsgWithdrawCollateral({
    required this.participant,
    required this.denom,
    required this.amount,
  });

  @override
  String get typeUrl => GonkaConstants.msgWithdrawCollateralTypeUrl;

  @override
  Uint8List encode() {
    final writer = ProtobufWriter();
    writer.writeString(1, participant);
    writer.writeMessage(2, _encodeCoin());
    return writer.toBytes();
  }

  Uint8List _encodeCoin() {
    final writer = ProtobufWriter();
    writer.writeString(1, denom);
    writer.writeString(2, amount);
    return writer.toBytes();
  }
}
