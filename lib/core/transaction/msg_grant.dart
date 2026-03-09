import 'dart:typed_data';
import '../../config/constants.dart';
import 'protobuf_utils.dart';
import 'tx_message.dart';

class MsgGrant implements TxMessage {
  final String granter;
  final String grantee;
  final String authorizedMsgTypeUrl;
  final DateTime expiration;

  MsgGrant({
    required this.granter,
    required this.grantee,
    required this.authorizedMsgTypeUrl,
    required this.expiration,
  });

  @override
  String get typeUrl => GonkaConstants.msgGrantTypeUrl;

  @override
  Uint8List encode() {
    final writer = ProtobufWriter();
    writer.writeString(1, granter);
    writer.writeString(2, grantee);
    writer.writeMessage(3, _encodeGrant());
    return writer.toBytes();
  }

  Uint8List _encodeGrant() {
    final grant = ProtobufWriter();
    grant.writeMessage(1, _encodeAuthorization());
    grant.writeMessage(2, _encodeTimestamp());
    return grant.toBytes();
  }

  Uint8List _encodeAuthorization() {
    final any = ProtobufWriter();
    any.writeString(1, '/cosmos.authz.v1beta1.GenericAuthorization');
    final generic = ProtobufWriter();
    generic.writeString(1, authorizedMsgTypeUrl);
    any.writeBytes(2, generic.toBytes());
    return any.toBytes();
  }

  Uint8List _encodeTimestamp() {
    final ts = ProtobufWriter();
    final seconds = expiration.millisecondsSinceEpoch ~/ 1000;
    final nanos = (expiration.millisecondsSinceEpoch % 1000) * 1000000;
    ts.writeUint64(1, seconds);
    if (nanos > 0) {
      ts.writeVarint(2, nanos);
    }
    return ts.toBytes();
  }
}

const List<String> mlOpsPermissions = [
  '/inference.inference.MsgStartInference',
  '/inference.inference.MsgFinishInference',
  '/inference.inference.MsgClaimRewards',
  '/inference.inference.MsgValidation',
  '/inference.inference.MsgSubmitPocBatch',
  '/inference.inference.MsgSubmitPocValidation',
  '/inference.inference.MsgSubmitPocValidationsV2',
  '/inference.inference.MsgPoCV2StoreCommit',
  '/inference.inference.MsgMLNodeWeightDistribution',
  '/inference.inference.MsgSubmitSeed',
  '/inference.inference.MsgBridgeExchange',
  '/inference.inference.MsgSubmitTrainingKvRecord',
  '/inference.inference.MsgJoinTraining',
  '/inference.inference.MsgJoinTrainingStatus',
  '/inference.inference.MsgTrainingHeartbeat',
  '/inference.inference.MsgSetBarrier',
  '/inference.inference.MsgClaimTrainingTaskForAssignment',
  '/inference.inference.MsgAssignTrainingTask',
  '/inference.inference.MsgSubmitNewUnfundedParticipant',
  '/inference.inference.MsgSubmitHardwareDiff',
  '/inference.inference.MsgInvalidateInference',
  '/inference.inference.MsgRevalidateInference',
  '/inference.bls.MsgSubmitDealerPart',
  '/inference.bls.MsgSubmitVerificationVector',
  '/inference.bls.MsgRequestThresholdSignature',
  '/inference.bls.MsgSubmitPartialSignature',
  '/inference.bls.MsgSubmitGroupKeyValidationSignature',
];

List<MsgGrant> buildMlOpsGrants({
  required String granter,
  required String grantee,
  Duration validity = const Duration(days: 730),
}) {
  final expiration = DateTime.now().toUtc().add(validity);
  return mlOpsPermissions
      .map((msgUrl) => MsgGrant(
            granter: granter,
            grantee: grantee,
            authorizedMsgTypeUrl: msgUrl,
            expiration: expiration,
          ))
      .toList();
}
