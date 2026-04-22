import 'dart:convert';
import 'dart:typed_data';
import '../../config/constants.dart';
import '../crypto/tx_signer.dart';
import 'protobuf_utils.dart';
import 'tx_message.dart';

class TxBuilder {
  static String buildAndSign({
    required TxMessage msg,
    required Uint8List publicKey,
    required Uint8List privateKey,
    required int accountNumber,
    required int sequence,
    String memo = '',
  }) {
    final bodyBytes = _buildTxBody(msg, memo);
    final authInfoBytes = _buildAuthInfo(publicKey, sequence);
    final signDocBytes = _buildSignDoc(
      bodyBytes: bodyBytes,
      authInfoBytes: authInfoBytes,
      chainId: GonkaConstants.chainId,
      accountNumber: accountNumber,
    );

    final hash = TxSigner.sha256Hash(signDocBytes);
    final signature = TxSigner.sign(hash, privateKey);

    final txRaw = _buildTxRaw(bodyBytes, authInfoBytes, signature);
    return base64Encode(txRaw);
  }

  static String buildAndSignMulti({
    required List<TxMessage> messages,
    required Uint8List publicKey,
    required Uint8List privateKey,
    required int accountNumber,
    required int sequence,
    String memo = '',
  }) {
    final bodyBytes = _buildTxBodyMulti(messages, memo);
    final authInfoBytes = _buildAuthInfo(publicKey, sequence);
    final signDocBytes = _buildSignDoc(
      bodyBytes: bodyBytes,
      authInfoBytes: authInfoBytes,
      chainId: GonkaConstants.chainId,
      accountNumber: accountNumber,
    );

    final hash = TxSigner.sha256Hash(signDocBytes);
    final signature = TxSigner.sign(hash, privateKey);

    final txRaw = _buildTxRaw(bodyBytes, authInfoBytes, signature);
    return base64Encode(txRaw);
  }

  static Uint8List signDirectFromBytes({
    required Uint8List bodyBytes,
    required Uint8List authInfoBytes,
    required String chainId,
    required int accountNumber,
    required Uint8List privateKey,
  }) {
    final signDocBytes = _buildSignDoc(
      bodyBytes: bodyBytes,
      authInfoBytes: authInfoBytes,
      chainId: chainId,
      accountNumber: accountNumber,
    );
    final hash = TxSigner.sha256Hash(signDocBytes);
    return TxSigner.sign(hash, privateKey);
  }

  static Uint8List _buildTxBodyMulti(List<TxMessage> messages, String memo) {
    final body = ProtobufWriter();
    for (final msg in messages) {
      final anyMsg = ProtobufWriter();
      anyMsg.writeString(1, msg.typeUrl);
      anyMsg.writeBytes(2, msg.encode());
      body.writeMessage(1, anyMsg.toBytes());
    }
    if (memo.isNotEmpty) {
      body.writeString(2, memo);
    }
    return body.toBytes();
  }

  static Uint8List _buildTxBody(TxMessage msg, String memo) {
    final anyMsg = ProtobufWriter();
    anyMsg.writeString(1, msg.typeUrl);
    anyMsg.writeBytes(2, msg.encode());
    final anyBytes = anyMsg.toBytes();

    final body = ProtobufWriter();
    body.writeMessage(1, anyBytes);
    if (memo.isNotEmpty) {
      body.writeString(2, memo);
    }
    return body.toBytes();
  }

  static Uint8List _buildAuthInfo(Uint8List publicKey, int sequence) {
    final pubKeyAny = ProtobufWriter();
    pubKeyAny.writeString(1, '/cosmos.crypto.secp256k1.PubKey');
    final pubKeyMsg = ProtobufWriter();
    pubKeyMsg.writeBytes(1, publicKey);
    pubKeyAny.writeBytes(2, pubKeyMsg.toBytes());

    final singleMode = ProtobufWriter();
    singleMode.writeVarint(1, 1);
    final modeInfo = ProtobufWriter();
    modeInfo.writeMessage(1, singleMode.toBytes());

    final signerInfo = ProtobufWriter();
    signerInfo.writeMessage(1, pubKeyAny.toBytes());
    signerInfo.writeMessage(2, modeInfo.toBytes());
    signerInfo.writeUint64(3, sequence);

    final fee = ProtobufWriter();
    fee.writeUint64(2, GonkaConstants.defaultGasLimit);

    final authInfo = ProtobufWriter();
    authInfo.writeMessage(1, signerInfo.toBytes());
    authInfo.writeMessage(2, fee.toBytes());
    return authInfo.toBytes();
  }

  static Uint8List _buildSignDoc({
    required Uint8List bodyBytes,
    required Uint8List authInfoBytes,
    required String chainId,
    required int accountNumber,
  }) {
    final signDoc = ProtobufWriter();
    signDoc.writeBytes(1, bodyBytes);
    signDoc.writeBytes(2, authInfoBytes);
    signDoc.writeString(3, chainId);
    signDoc.writeUint64(4, accountNumber);
    return signDoc.toBytes();
  }

  static Uint8List _buildTxRaw(
    Uint8List bodyBytes,
    Uint8List authInfoBytes,
    Uint8List signature,
  ) {
    final txRaw = ProtobufWriter();
    txRaw.writeBytes(1, bodyBytes);
    txRaw.writeBytes(2, authInfoBytes);
    txRaw.writeBytes(3, signature);
    return txRaw.toBytes();
  }
}
