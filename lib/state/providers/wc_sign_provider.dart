import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex/hex.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import '../../core/crypto/hd_key_service.dart';
import '../../core/transaction/tx_builder.dart';
import '../../core/walletconnect/sign_direct_decoder.dart';
import '../../core/walletconnect/wc_service.dart';
import 'wallet_provider.dart';
import 'wc_provider.dart';

final wcSignProvider =
    StateNotifierProvider<WcSignNotifier, AsyncValue<void>>((ref) {
  return WcSignNotifier(ref);
});

class WcSignNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  WcSignNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> sign({
    required int requestId,
    required String topic,
    required String walletId,
    required SignDirectPayload payload,
  }) async {
    state = const AsyncValue.loading();
    Uint8List? privateKey;
    try {
      final pkHex =
          await _ref.read(walletsProvider.notifier).getPrivateKeyHex(walletId);
      if (pkHex == null) {
        throw StateError('Private key not available for wallet $walletId');
      }
      privateKey = Uint8List.fromList(HEX.decode(pkHex));
      final publicKey = HDKeyService.publicKeyFromPrivate(privateKey);

      final signature = TxBuilder.signDirectFromBytes(
        bodyBytes: payload.bodyBytes,
        authInfoBytes: payload.authInfoBytes,
        chainId: payload.chainId,
        accountNumber: payload.accountNumber,
        privateKey: privateKey,
      );

      final result = SignDirectDecoder.buildResult(
        payload: payload,
        signature: signature,
        publicKey: publicKey,
      );

      final wc = _ref.read(wcServiceProvider);
      await wc.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(id: requestId, result: result),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      final wc = _ref.read(wcServiceProvider);
      try {
        await wc.respondSessionRequest(
          topic: topic,
          response: JsonRpcResponse(
            id: requestId,
            error: const JsonRpcError(code: -32000, message: 'sign failed'),
          ),
        );
      } catch (_) {}
      state = AsyncValue.error(e, st);
      rethrow;
    } finally {
      if (privateKey != null) HDKeyService.zeroKey(privateKey);
    }
  }

  Future<void> reject({
    required int requestId,
    required String topic,
  }) async {
    final wc = _ref.read(wcServiceProvider);
    final err = WcService.sdkError(Errors.USER_REJECTED_SIGN);
    await wc.respondSessionRequest(
      topic: topic,
      response: JsonRpcResponse(
        id: requestId,
        error: JsonRpcError(code: err.code, message: err.message),
      ),
    );
  }
}
