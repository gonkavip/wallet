import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/send_provider.dart';
import '../../widgets/address_display.dart';
import '../../widgets/amount_display.dart';
import '../../widgets/responsive_center.dart';

class ConfirmSendScreen extends ConsumerStatefulWidget {
  final String toAddress;
  final String amountNgonka;

  const ConfirmSendScreen({
    super.key,
    required this.toAddress,
    required this.amountNgonka,
  });

  @override
  ConsumerState<ConfirmSendScreen> createState() => _ConfirmSendScreenState();
}

class _ConfirmSendScreenState extends ConsumerState<ConfirmSendScreen> {
  bool _authenticating = false;

  Future<void> _authenticate() async {
    setState(() => _authenticating = true);
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);
    final reason = AppLocalizations.of(context).authBiometricReason;

    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final success = await auth.authenticateBiometric(reason: reason);
      if (success) {
        setState(() {
          _authenticating = false;
        });
        _send();
        return;
      }
    }

    if (!mounted) return;
    final success = await context.push<bool>('/auth/pin-verify') ?? false;
    if (success) {
      setState(() => _authenticating = false);
      _send();
      return;
    }
    setState(() => _authenticating = false);
  }

  void _send() async {
    final wallet = ref.read(activeWalletProvider);
    if (wallet == null) return;

    await ref.read(sendProvider.notifier).send(
          walletId: wallet.id,
          fromAddress: wallet.address,
          toAddress: widget.toAddress,
          amountNgonka: widget.amountNgonka,
        );

    if (!mounted) return;
    final result = ref.read(sendProvider);
    context.push('/send/result', extra: {
      'txhash': result.txhash ?? '',
      'error': result.error ?? '',
      'success': result.state == SendState.success,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallet = ref.watch(activeWalletProvider);
    final amount = BigInt.parse(widget.amountNgonka);
    final sendResult = ref.watch(sendProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.confirmSendTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.commonFrom,
                style: Theme.of(context).textTheme.bodySmall),
            if (wallet != null) AddressDisplay(address: wallet.address),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text(l10n.commonTo,
                style: Theme.of(context).textTheme.bodySmall),
            AddressDisplay(address: widget.toAddress, compact: false),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text(l10n.commonAmount,
                style: Theme.of(context).textTheme.bodySmall),
            AmountDisplay(amountNgonka: amount, exact: true),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text(l10n.commonFee,
                style: Theme.of(context).textTheme.bodySmall),
            Text(l10n.commonFeeZero,
                style: Theme.of(context).textTheme.titleMedium),

            const Spacer(),

            if (sendResult.state == SendState.signing ||
                sendResult.state == SendState.broadcasting)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _authenticating ? null : _authenticate,
                  child: Text(_authenticating
                      ? l10n.confirmSendAuthenticating
                      : l10n.confirmSendButton),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
