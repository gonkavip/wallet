import '../crypto/address_service.dart';
import '../crypto/hd_key_service.dart';
import '../network/node_client.dart';
import '../network/node_manager.dart';
import 'msg_collateral.dart';
import 'msg_grant.dart';
import 'msg_send.dart';
import 'msg_unjail.dart';
import 'msg_vote.dart';
import 'tx_builder.dart';

class BroadcastService {
  final NodeManager _nodeManager;

  BroadcastService(this._nodeManager);

  Future<BroadcastResult> send({
    required String mnemonic,
    required String fromAddress,
    required String toAddress,
    required String amount,
    String memo = '',
  }) async {
    final client = _nodeManager.client;
    if (client == null) throw Exception('No active node');

    final accountInfo = await client.getAccountInfo(fromAddress);

    final privateKey = HDKeyService.derivePrivateKey(mnemonic);
    final publicKey = HDKeyService.derivePublicKey(mnemonic);

    try {
      final msg = MsgSend(
        fromAddress: fromAddress,
        toAddress: toAddress,
        denom: 'ngonka',
        amount: amount,
      );

      final txBase64 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: publicKey,
        privateKey: privateKey,
        accountNumber: accountInfo.accountNumber,
        sequence: accountInfo.sequence,
        memo: memo,
      );

      final result = await client.broadcastTx(txBase64);
      _nodeManager.reportSuccess();
      return result;
    } catch (e) {
      _nodeManager.reportError();
      rethrow;
    } finally {
      HDKeyService.zeroKey(privateKey);
    }
  }
  Future<BroadcastResult> depositCollateral({
    required String mnemonic,
    required String fromAddress,
    required String amount,
  }) async {
    final client = _nodeManager.client;
    if (client == null) throw Exception('No active node');

    final accountInfo = await client.getAccountInfo(fromAddress);
    final privateKey = HDKeyService.derivePrivateKey(mnemonic);
    final publicKey = HDKeyService.derivePublicKey(mnemonic);

    try {
      final msg = MsgDepositCollateral(
        participant: fromAddress,
        denom: 'ngonka',
        amount: amount,
      );

      final txBase64 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: publicKey,
        privateKey: privateKey,
        accountNumber: accountInfo.accountNumber,
        sequence: accountInfo.sequence,
      );

      final result = await client.broadcastTx(txBase64);
      _nodeManager.reportSuccess();
      return result;
    } catch (e) {
      _nodeManager.reportError();
      rethrow;
    } finally {
      HDKeyService.zeroKey(privateKey);
    }
  }

  Future<BroadcastResult> grantMlOpsPermissions({
    required String mnemonic,
    required String fromAddress,
    required String granteeAddress,
  }) async {
    final client = _nodeManager.client;
    if (client == null) throw Exception('No active node');

    final accountInfo = await client.getAccountInfo(fromAddress);
    final privateKey = HDKeyService.derivePrivateKey(mnemonic);
    final publicKey = HDKeyService.derivePublicKey(mnemonic);

    try {
      final messages = buildMlOpsGrants(
        granter: fromAddress,
        grantee: granteeAddress,
      );

      final txBase64 = TxBuilder.buildAndSignMulti(
        messages: messages,
        publicKey: publicKey,
        privateKey: privateKey,
        accountNumber: accountInfo.accountNumber,
        sequence: accountInfo.sequence,
      );

      final result = await client.broadcastTx(txBase64);
      _nodeManager.reportSuccess();
      return result;
    } catch (e) {
      _nodeManager.reportError();
      rethrow;
    } finally {
      HDKeyService.zeroKey(privateKey);
    }
  }

  Future<BroadcastResult> unjail({
    required String mnemonic,
    required String fromAddress,
  }) async {
    final client = _nodeManager.client;
    if (client == null) throw Exception('No active node');

    final accountInfo = await client.getAccountInfo(fromAddress);
    final privateKey = HDKeyService.derivePrivateKey(mnemonic);
    final publicKey = HDKeyService.derivePublicKey(mnemonic);

    try {
      final valoperAddr = AddressService.toValoperAddress(fromAddress);
      final msg = MsgUnjail(validatorAddr: valoperAddr);

      final txBase64 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: publicKey,
        privateKey: privateKey,
        accountNumber: accountInfo.accountNumber,
        sequence: accountInfo.sequence,
      );

      final result = await client.broadcastTx(txBase64);
      _nodeManager.reportSuccess();

      if (result.isSuccess && result.txhash.isNotEmpty) {
        final confirmed = await _confirmTx(client, result.txhash);
        if (confirmed != null) return confirmed;
      }

      return result;
    } catch (e) {
      _nodeManager.reportError();
      rethrow;
    } finally {
      HDKeyService.zeroKey(privateKey);
    }
  }

  Future<BroadcastResult?> _confirmTx(NodeClient client, String txhash) async {
    for (var i = 0; i < 6; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final onChain = await client.getTxByHash(txhash);
      if (onChain != null) return onChain;
    }
    return null;
  }

  Future<BroadcastResult> vote({
    required String mnemonic,
    required String fromAddress,
    required int proposalId,
    required VoteOption option,
  }) async {
    final client = _nodeManager.client;
    if (client == null) throw Exception('No active node');

    final accountInfo = await client.getAccountInfo(fromAddress);
    final privateKey = HDKeyService.derivePrivateKey(mnemonic);
    final publicKey = HDKeyService.derivePublicKey(mnemonic);

    try {
      final msg = MsgVote(
        proposalId: proposalId,
        voter: fromAddress,
        option: option,
      );

      final txBase64 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: publicKey,
        privateKey: privateKey,
        accountNumber: accountInfo.accountNumber,
        sequence: accountInfo.sequence,
      );

      final result = await client.broadcastTx(txBase64);
      _nodeManager.reportSuccess();

      if (result.isSuccess && result.txhash.isNotEmpty) {
        final confirmed = await _confirmTx(client, result.txhash);
        if (confirmed != null) return confirmed;
      }

      return result;
    } catch (e) {
      _nodeManager.reportError();
      rethrow;
    } finally {
      HDKeyService.zeroKey(privateKey);
    }
  }

  Future<BroadcastResult> withdrawCollateral({
    required String mnemonic,
    required String fromAddress,
    required String amount,
  }) async {
    final client = _nodeManager.client;
    if (client == null) throw Exception('No active node');

    final accountInfo = await client.getAccountInfo(fromAddress);
    final privateKey = HDKeyService.derivePrivateKey(mnemonic);
    final publicKey = HDKeyService.derivePublicKey(mnemonic);

    try {
      final msg = MsgWithdrawCollateral(
        participant: fromAddress,
        denom: 'ngonka',
        amount: amount,
      );

      final txBase64 = TxBuilder.buildAndSign(
        msg: msg,
        publicKey: publicKey,
        privateKey: privateKey,
        accountNumber: accountInfo.accountNumber,
        sequence: accountInfo.sequence,
      );

      final result = await client.broadcastTx(txBase64);
      _nodeManager.reportSuccess();
      return result;
    } catch (e) {
      _nodeManager.reportError();
      rethrow;
    } finally {
      HDKeyService.zeroKey(privateKey);
    }
  }
}
