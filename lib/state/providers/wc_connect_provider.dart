import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import '../../core/walletconnect/wc_constants.dart';
import '../../core/walletconnect/wc_namespace_builder.dart';
import '../../core/walletconnect/wc_service.dart';
import '../../core/walletconnect/wc_uri_parser.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/wc_session.dart';
import 'wallet_provider.dart';
import 'wc_provider.dart';

final wcConnectProvider =
    StateNotifierProvider<WcConnectNotifier, AsyncValue<void>>((ref) {
  return WcConnectNotifier(ref);
});

class WcConnectError implements Exception {
  final String code;
  WcConnectError(this.code);
  @override
  String toString() => 'WcConnectError($code)';
}

class WcConnectNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  WcConnectNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> pair(String rawInput) async {
    final uri = WcUriParser.extractFromString(rawInput);
    if (uri == null) {
      throw WcConnectError('invalidUri');
    }
    final parsed = WcUriParser.parse(uri);
    if (parsed == null) {
      throw WcConnectError('invalidUri');
    }
    if (parsed.isExpired) {
      throw WcConnectError('expiredUri');
    }
    final wallets = _ref.read(walletsProvider);
    if (wallets.isEmpty) {
      throw WcConnectError('noWallets');
    }

    state = const AsyncValue.loading();
    try {
      final wc = _ref.read(wcServiceProvider);
      await wc.pair(Uri.parse(uri));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> approve({
    required int proposalId,
    required String pairingTopic,
    required WalletModel wallet,
    required String dappName,
    String? dappUrl,
    String? dappIcon,
    String? dappDescription,
  }) async {
    state = const AsyncValue.loading();
    try {
      final wc = _ref.read(wcServiceProvider);
      final namespaces = WcNamespaceBuilder.buildApprovedNamespaces(
        walletAddress: wallet.address,
      );
      final response = await wc.approveSession(
        id: proposalId,
        namespaces: namespaces,
      );
      final topic = response.topic;
      final session = WcSession(
        topic: topic,
        walletId: wallet.id,
        walletAddress: wallet.address,
        dappName: dappName,
        dappUrl: dappUrl,
        dappIconUrl: dappIcon,
        dappDescription: dappDescription,
        chains: const [WcConstants.caipChainId],
        methods: WcConstants.supportedMethods,
        approvedAt: DateTime.now(),
      );
      await _ref
          .read(wcSessionsProvider.notifier)
          .addSession(session);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> reject(int proposalId) async {
    final wc = _ref.read(wcServiceProvider);
    await wc.rejectSession(
      id: proposalId,
      reason: WcService.sdkError(Errors.USER_REJECTED),
    );
  }

  Future<void> disconnect(String topic) async {
    final wc = _ref.read(wcServiceProvider);
    try {
      await wc.disconnectSession(
        topic: topic,
        reason: WcService.sdkError(Errors.USER_REJECTED),
      );
    } catch (_) {}
    await _ref.read(wcSessionsProvider.notifier).removeSession(topic);
  }
}
