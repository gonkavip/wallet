import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/collateral_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../widgets/address_display.dart';
import '../../widgets/amount_display.dart';
import '../../widgets/responsive_center.dart';

class CollateralConfirmScreen extends ConsumerStatefulWidget {
  final String amountNgonka;
  final bool isDeposit;

  const CollateralConfirmScreen({
    super.key,
    required this.amountNgonka,
    required this.isDeposit,
  });

  @override
  ConsumerState<CollateralConfirmScreen> createState() =>
      _CollateralConfirmScreenState();
}

class _CollateralConfirmScreenState
    extends ConsumerState<CollateralConfirmScreen> {
  bool _authenticating = false;
  bool _broadcasting = false;

  Future<void> _authenticate() async {
    setState(() => _authenticating = true);
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);
    final reason = AppLocalizations.of(context).authBiometricReason;

    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final success = await auth.authenticateBiometric(reason: reason);
      if (success) {
        setState(() => _authenticating = false);
        _execute();
        return;
      }
    }

    if (!mounted) return;
    final success = await context.push<bool>('/auth/pin-verify') ?? false;
    if (success) {
      setState(() => _authenticating = false);
      _execute();
      return;
    }
    setState(() => _authenticating = false);
  }

  void _execute() async {
    final wallet = ref.read(activeWalletProvider);
    if (wallet == null) return;

    setState(() => _broadcasting = true);

    if (widget.isDeposit) {
      await ref.read(collateralProvider.notifier).deposit(
            walletId: wallet.id,
            address: wallet.address,
            amountNgonka: widget.amountNgonka,
          );
    } else {
      await ref.read(collateralProvider.notifier).withdraw(
            walletId: wallet.id,
            address: wallet.address,
            amountNgonka: widget.amountNgonka,
          );
    }

    if (!mounted) return;
    final state = ref.read(collateralProvider);
    final result = state.lastTxResult;

    context.push('/miners/collateral/result', extra: {
      'success': result != null && result.isSuccess,
      'txhash': result?.txhash ?? '',
      'error': state.error ?? result?.rawLog ?? '',
      'isDeposit': widget.isDeposit,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallet = ref.watch(activeWalletProvider);
    final amount = BigInt.parse(widget.amountNgonka);
    final title = widget.isDeposit
        ? l10n.collateralConfirmDeposit
        : l10n.collateralConfirmWithdraw;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/miners/collateral');
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
            Text(l10n.commonAction,
                style: Theme.of(context).textTheme.bodySmall),
            Text(
                widget.isDeposit
                    ? l10n.collateralDepositTitle
                    : l10n.collateralWithdrawTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text(l10n.commonAddress,
                style: Theme.of(context).textTheme.bodySmall),
            if (wallet != null) AddressDisplay(address: wallet.address),
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

            if (_broadcasting)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _authenticating ? null : _authenticate,
                  child: Text(_authenticating
                      ? l10n.confirmSendAuthenticating
                      : (widget.isDeposit
                          ? l10n.collateralConfirmDepositButton
                          : l10n.collateralConfirmWithdrawButton)),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
