import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/wc_provider.dart';
import '../../../state/providers/wc_sign_provider.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/wc_dapp_header.dart';
import '../../widgets/wc_message_card.dart';

class WcSignRequestScreen extends ConsumerStatefulWidget {
  const WcSignRequestScreen({super.key});

  @override
  ConsumerState<WcSignRequestScreen> createState() =>
      _WcSignRequestScreenState();
}

class _WcSignRequestScreenState
    extends ConsumerState<WcSignRequestScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final request = ref.watch(wcActiveSignRequestProvider);
    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.wcSignTitle)),
        body: Center(
          child: Text(l10n.wcErrorGeneric('no pending request')),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) await _reject();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.wcSignTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _reject();
              if (!mounted) return;
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        body: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              WcDappHeader(
                name: request.dappName,
                iconUrl: request.dappIcon,
              ),
              const SizedBox(height: 16),
              _labelRow(l10n.wcSignSigner, request.signerAddress),
              const SizedBox(height: 16),
              ...request.txBody.messages.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WcMessageCard(message: m),
                  )),
              if (request.txBody.memo.isNotEmpty) ...[
                const SizedBox(height: 8),
                _labelRow(l10n.wcSignMemo, request.txBody.memo),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _onReject,
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56)),
                      child: Text(l10n.wcSignReject),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : _onApprove,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 56)),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.wcSignApprove),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: GonkaColors.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: GonkaColors.textPrimary,
                    fontSize: 13,
                    fontFamily: 'monospace')),
          ],
        ),
      );

  Future<void> _reject() async {
    final req = ref.read(wcActiveSignRequestProvider);
    if (req == null) return;
    try {
      await ref
          .read(wcSignProvider.notifier)
          .reject(requestId: req.requestId, topic: req.topic);
    } catch (_) {}
    ref.read(wcActiveSignRequestProvider.notifier).state = null;
  }

  Future<void> _onReject() async {
    await _reject();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _onApprove() async {
    final req = ref.read(wcActiveSignRequestProvider);
    if (req == null) return;

    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);
    final reason = AppLocalizations.of(context).wcBiometricReason;

    bool authenticated = false;
    if (await storage.isBiometricEnabled()) {
      authenticated = await auth.authenticateBiometric(reason: reason);
    }
    if (!authenticated && mounted) {
      authenticated = await context.push<bool>('/auth/pin-verify') ?? false;
    }
    if (!authenticated) return;

    setState(() => _busy = true);
    try {
      await ref.read(wcSignProvider.notifier).sign(
            requestId: req.requestId,
            topic: req.topic,
            walletId: req.walletId,
            payload: req.payload,
          );
      ref.read(wcActiveSignRequestProvider.notifier).state = null;
      if (!mounted) return;
      if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).wcErrorGeneric('$e')),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
