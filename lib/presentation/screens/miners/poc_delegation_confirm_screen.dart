import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/poc_delegation_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../widgets/address_display.dart';
import '../../widgets/responsive_center.dart';

class PocDelegationConfirmScreen extends ConsumerStatefulWidget {
  final String modelId;

  final String delegateTo;

  const PocDelegationConfirmScreen({
    super.key,
    required this.modelId,
    required this.delegateTo,
  });

  @override
  ConsumerState<PocDelegationConfirmScreen> createState() =>
      _PocDelegationConfirmScreenState();
}

class _PocDelegationConfirmScreenState
    extends ConsumerState<PocDelegationConfirmScreen> {
  bool _authenticating = false;
  bool _broadcasting = false;

  bool get _isClear => widget.delegateTo.isEmpty;

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

    await ref.read(pocDelegationProvider.notifier).delegate(
          walletId: wallet.id,
          fromAddress: wallet.address,
          modelId: widget.modelId,
          delegateTo: widget.delegateTo,
        );

    if (!mounted) return;
    final state = ref.read(pocDelegationProvider);
    final result = state.lastTxResult;

    context.push('/miners/poc-delegation/result', extra: {
      'success': result != null && result.isSuccess,
      'txhash': result?.txhash ?? '',
      'error': state.error ?? result?.rawLog ?? '',
      'isClear': _isClear,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _isClear
        ? l10n.pocDelegationConfirmClearTitle
        : l10n.pocDelegationConfirmTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/miners/poc-delegation');
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
                _isClear
                    ? l10n.pocDelegationClear
                    : l10n.pocDelegationDelegate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              Text(l10n.pocDelegationModelLabel,
                  style: Theme.of(context).textTheme.bodySmall),
              Text(widget.modelId,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              if (!_isClear) ...[
                Text(l10n.pocDelegationAddressLabel,
                    style: Theme.of(context).textTheme.bodySmall),
                AddressDisplay(address: widget.delegateTo),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
              ],

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
                        : (_isClear
                            ? l10n.pocDelegationClear
                            : l10n.pocDelegationDelegate)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
