import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/crypto/address_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/unjail_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../error_l10n.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

class UnjailScreen extends ConsumerStatefulWidget {
  const UnjailScreen({super.key});

  @override
  ConsumerState<UnjailScreen> createState() => _UnjailScreenState();
}

class _UnjailScreenState extends ConsumerState<UnjailScreen> {
  bool _authenticating = false;
  bool _broadcasting = false;
  bool _done = false;
  bool _success = false;
  String _txhash = '';
  String _error = '';

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

    await ref.read(unjailProvider.notifier).unjail(
          walletId: wallet.id,
          fromAddress: wallet.address,
        );

    if (!mounted) return;
    final state = ref.read(unjailProvider);
    final result = state.lastTxResult;

    setState(() {
      _broadcasting = false;
      _done = true;
      _success = result != null && result.isSuccess;
      _txhash = result?.txhash ?? '';
      _error = state.error ?? result?.rawLog ?? '';
    });
  }

  void _retry() {
    ref.read(unjailProvider.notifier).clearResult();
    setState(() {
      _done = false;
      _success = false;
      _txhash = '';
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(activeWalletProvider);
    final valoperAddr = wallet != null
        ? AddressService.toValoperAddress(wallet.address)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).unjailTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/miners');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: _done
              ? _buildResult(context)
              : _buildConfirm(context, wallet, valoperAddr),
        ),
      ),
    );
  }

  Widget _buildConfirm(BuildContext context, wallet, String valoperAddr) {
    final address = wallet?.address ?? '';
    final jailedAsync = ref.watch(validatorJailedProvider(address));

    return jailedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildConfirmBody(context, valoperAddr, jailed: null),
      data: (jailed) =>
          _buildConfirmBody(context, valoperAddr, jailed: jailed),
    );
  }

  Widget _buildConfirmBody(BuildContext context, String valoperAddr,
      {required bool? jailed}) {
    final l10n = AppLocalizations.of(context);
    final bool canUnjail = jailed == true;

    final InfoBannerVariant variant;
    final String infoText;

    if (jailed == true) {
      variant = InfoBannerVariant.warning;
      infoText = l10n.unjailWarningJailed;
    } else if (jailed == false) {
      variant = InfoBannerVariant.success;
      infoText = l10n.unjailInfoNotJailed;
    } else {
      variant = InfoBannerVariant.info;
      infoText = l10n.unjailInfoNotFound;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoBanner(variant: variant, message: infoText),
        const SizedBox(height: 24),

        Text(l10n.commonAction,
            style: const TextStyle(
                color: GonkaColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)),
        const SizedBox(height: 4),
        Text(l10n.unjailAction,
            style: const TextStyle(
                color: GonkaColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        Text(l10n.unjailValidatorAddress,
            style: const TextStyle(
                color: GonkaColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)),
        const SizedBox(height: 6),
        Text(
          valoperAddr,
          style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: GonkaColors.textPrimary),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        Text(l10n.commonFee,
            style: const TextStyle(
                color: GonkaColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)),
        const SizedBox(height: 4),
        Text(l10n.commonFeeZero,
            style: const TextStyle(
                color: GonkaColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),

        const Spacer(),

        if (_broadcasting)
          const Center(child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  canUnjail && !_authenticating ? _authenticate : null,
              child: Text(_authenticating
                  ? l10n.confirmSendAuthenticating
                  : l10n.unjailConfirmButton),
            ),
          ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const Spacer(),
        ResultIcon(success: _success),
        const SizedBox(height: 28),
        Text(
          _success ? l10n.unjailResultSuccess : l10n.unjailResultFailed,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: GonkaColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 20),
        if (_success && _txhash.isNotEmpty) TxHashDisplay(hash: _txhash),
        if (!_success && _error.isNotEmpty)
          InfoBanner(
            variant: InfoBannerVariant.error,
            message: localizeError(l10n, _error),
          ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/miners');
              }
            },
            child: Text(l10n.commonDone),
          ),
        ),
        if (!_success) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _retry,
              child: Text(l10n.commonRetry),
            ),
          ),
        ],
      ],
    );
  }
}
