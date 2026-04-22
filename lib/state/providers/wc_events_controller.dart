import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex/hex.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import '../../app.dart' show appRouter;
import '../../config/constants.dart';
import '../../core/crypto/hd_key_service.dart';
import '../../core/walletconnect/sign_direct_decoder.dart';
import '../../core/walletconnect/tx_body_decoder.dart';
import '../../core/walletconnect/wc_constants.dart';
import '../../core/walletconnect/wc_namespace_builder.dart';
import '../../core/walletconnect/wc_service.dart';
import '../../data/models/wc_proposal_view.dart';
import '../../data/models/wc_sign_request_view.dart';
import 'wallet_provider.dart';
import 'wc_provider.dart';

final wcEventsProvider = Provider<WcEventsController>((ref) {
  final controller = WcEventsController(ref);
  controller.start();
  ref.onDispose(controller.stop);
  return controller;
});

class WcEventsController {
  final Ref _ref;
  bool _started = false;

  WcEventsController(this._ref);

  void start() {
    if (_started) return;
    final wc = _ref.read(wcServiceProvider);
    wc.onSessionProposal.subscribe(_handleProposal);
    wc.onSessionRequest.subscribe(_handleRequest);
    wc.onSessionDelete.subscribe(_handleDelete);
    wc.onSessionExpire.subscribe(_handleExpire);
    _started = true;
  }

  void stop() {
    if (!_started) return;
    final wc = _ref.read(wcServiceProvider);
    wc.onSessionProposal.unsubscribe(_handleProposal);
    wc.onSessionRequest.unsubscribe(_handleRequest);
    wc.onSessionDelete.unsubscribe(_handleDelete);
    wc.onSessionExpire.unsubscribe(_handleExpire);
    _started = false;
  }

  Future<void> _handleProposal(SessionProposalEvent? event) async {
    if (event == null) return;
    final proposal = event.params;
    final wc = _ref.read(wcServiceProvider);

    final wallets = _ref.read(walletsProvider);
    if (wallets.isEmpty) {
      await wc.rejectSession(
        id: event.id,
        reason: WcService.sdkError(Errors.UNSUPPORTED_ACCOUNTS),
      );
      return;
    }

    if (_ref.read(wcActiveProposalProvider) != null) {
      await wc.rejectSession(
        id: event.id,
        reason: WcService.sdkError(Errors.USER_REJECTED),
      );
      return;
    }

    final validation = WcNamespaceBuilder.validateProposal(proposal);
    final cosmosReq =
        proposal.requiredNamespaces[WcConstants.cosmosNamespace];
    final cosmosOpt =
        proposal.optionalNamespaces[WcConstants.cosmosNamespace];

    final view = WcProposalView(
      id: event.id,
      pairingTopic: proposal.pairingTopic,
      dappName: proposal.proposer.metadata.name,
      dappUrl: proposal.proposer.metadata.url,
      dappIcon: proposal.proposer.metadata.icons.isNotEmpty
          ? proposal.proposer.metadata.icons.first
          : null,
      dappDescription: proposal.proposer.metadata.description,
      requiredChains: cosmosReq?.chains ?? const [],
      requiredMethods: cosmosReq?.methods ?? const [],
      optionalChains: cosmosOpt?.chains ?? const [],
      optionalMethods: cosmosOpt?.methods ?? const [],
      validation: validation,
    );
    _ref.read(wcActiveProposalProvider.notifier).state = view;
    final pendingWalletId = _ref.read(wcPendingWalletIdProvider);
    _ref.read(wcPendingWalletIdProvider.notifier).state = null;
    appRouter.push('/wc/approve', extra: pendingWalletId);
  }

  Future<void> _handleRequest(SessionRequestEvent? event) async {
    if (event == null) return;
    final wc = _ref.read(wcServiceProvider);

    if (event.method == WcConstants.methodGetAccounts) {
      await _respondGetAccounts(event);
      return;
    }
    if (event.method != WcConstants.methodSignDirect) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: const JsonRpcError(
            code: 5101,
            message: 'Unsupported method',
          ),
        ),
      );
      return;
    }

    final repo = _ref.read(wcSessionRepositoryProvider);
    final session = repo.get(event.topic);
    if (session == null) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: const JsonRpcError(
            code: -32000,
            message: 'Unknown session',
          ),
        ),
      );
      return;
    }

    SignDirectPayload payload;
    try {
      payload = SignDirectDecoder.parse(event.params);
    } catch (e) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: JsonRpcError(code: -32602, message: 'Invalid params: $e'),
        ),
      );
      return;
    }

    if (payload.signerAddress != session.walletAddress) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: const JsonRpcError(
            code: -32000,
            message: 'Signer address mismatch',
          ),
        ),
      );
      return;
    }

    if (payload.chainId != GonkaConstants.chainId) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: const JsonRpcError(
            code: -32000,
            message: 'Chain mismatch',
          ),
        ),
      );
      return;
    }

    final txBody = TxBodyDecoder.decode(payload.bodyBytes);
    final view = WcSignRequestView(
      requestId: event.id,
      topic: event.topic,
      dappName: session.dappName,
      dappIcon: session.dappIconUrl,
      walletId: session.walletId,
      signerAddress: payload.signerAddress,
      payload: payload,
      txBody: txBody,
    );

    if (_ref.read(wcActiveSignRequestProvider) != null) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: const JsonRpcError(
            code: 4001,
            message: 'Another request is pending',
          ),
        ),
      );
      return;
    }

    _ref.read(wcActiveSignRequestProvider.notifier).state = view;
    appRouter.push('/wc/sign');
  }

  Future<void> _respondGetAccounts(SessionRequestEvent event) async {
    final wc = _ref.read(wcServiceProvider);
    final repo = _ref.read(wcSessionRepositoryProvider);
    final session = repo.get(event.topic);
    if (session == null) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: const JsonRpcError(
            code: -32000,
            message: 'Unknown session',
          ),
        ),
      );
      return;
    }
    Uint8List? privateKey;
    try {
      final pkHex = await _ref
          .read(walletsProvider.notifier)
          .getPrivateKeyHex(session.walletId);
      if (pkHex == null) {
        await wc.respondSessionRequest(
          topic: event.topic,
          response: JsonRpcResponse(
            id: event.id,
            error: const JsonRpcError(
              code: -32000,
              message: 'Private key unavailable',
            ),
          ),
        );
        return;
      }
      privateKey = Uint8List.fromList(HEX.decode(pkHex));
      final publicKey = HDKeyService.publicKeyFromPrivate(privateKey);
      final result = [
        {
          'address': session.walletAddress,
          'algo': 'secp256k1',
          'pubkey': base64Encode(publicKey),
        }
      ];
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(id: event.id, result: result),
      );
    } catch (e) {
      await wc.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          error: JsonRpcError(code: -32000, message: 'getAccounts failed: $e'),
        ),
      );
    } finally {
      if (privateKey != null) HDKeyService.zeroKey(privateKey);
    }
  }

  Future<void> _handleDelete(SessionDelete? event) async {
    if (event == null) return;
    await _ref.read(wcSessionsProvider.notifier).removeSession(event.topic);
    final currentSign = _ref.read(wcActiveSignRequestProvider);
    if (currentSign != null && currentSign.topic == event.topic) {
      _ref.read(wcActiveSignRequestProvider.notifier).state = null;
      if (appRouter.canPop()) appRouter.pop();
    }
  }

  Future<void> _handleExpire(SessionExpire? event) async {
    if (event == null) return;
    await _ref.read(wcSessionsProvider.notifier).removeSession(event.topic);
  }
}
