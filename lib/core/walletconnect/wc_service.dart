import 'package:reown_walletkit/reown_walletkit.dart';
import 'wc_constants.dart';

class WcService {
  ReownWalletKit? _walletKit;

  ReownWalletKit get walletKit {
    final kit = _walletKit;
    if (kit == null) {
      throw StateError('WcService.init() must be called before use');
    }
    return kit;
  }

  bool get isInitialized => _walletKit != null;

  Future<void> init() async {
    if (_walletKit != null) return;
    if (WcConstants.projectId.isEmpty) {
      throw StateError(
        'WalletConnect projectId is not configured. Get one at '
        'https://cloud.reown.com and pass it via '
        '--dart-define=WC_PROJECT_ID=<your-id>',
      );
    }
    _walletKit = await ReownWalletKit.createInstance(
      projectId: WcConstants.projectId,
      metadata: const PairingMetadata(
        name: WcConstants.appName,
        description: WcConstants.appDescription,
        url: WcConstants.appUrl,
        icons: [WcConstants.appIconUrl],
        redirect: Redirect(
          native: WcConstants.appRedirectNative,
          universal: WcConstants.appRedirectUniversal,
        ),
      ),
    );
  }

  Future<PairingInfo> pair(Uri uri) => walletKit.pair(uri: uri);

  Future<ApproveResponse> approveSession({
    required int id,
    required Map<String, Namespace> namespaces,
  }) => walletKit.approveSession(id: id, namespaces: namespaces);

  Future<void> rejectSession({
    required int id,
    required ReownSignError reason,
  }) => walletKit.rejectSession(id: id, reason: reason);

  Future<void> disconnectSession({
    required String topic,
    required ReownSignError reason,
  }) => walletKit.disconnectSession(topic: topic, reason: reason);

  Future<void> respondSessionRequest({
    required String topic,
    required JsonRpcResponse response,
  }) => walletKit.respondSessionRequest(topic: topic, response: response);

  Map<String, SessionData> getActiveSessions() => walletKit.getActiveSessions();

  Event<SessionProposalEvent> get onSessionProposal =>
      walletKit.onSessionProposal;
  Event<SessionRequestEvent> get onSessionRequest => walletKit.onSessionRequest;
  Event<SessionDelete> get onSessionDelete => walletKit.onSessionDelete;
  Event<SessionExpire> get onSessionExpire => walletKit.onSessionExpire;
  Event<SessionConnect> get onSessionConnect => walletKit.onSessionConnect;

  static ReownSignError sdkError(String key) {
    final coreError = Errors.getSdkError(key);
    return ReownSignError(
      code: coreError.code,
      message: coreError.message,
    );
  }
}
