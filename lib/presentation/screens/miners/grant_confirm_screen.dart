import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../state/providers/grant_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../widgets/address_display.dart';
import '../../widgets/responsive_center.dart';

class GrantConfirmScreen extends ConsumerStatefulWidget {
  final String granteeAddress;

  const GrantConfirmScreen({
    super.key,
    required this.granteeAddress,
  });

  @override
  ConsumerState<GrantConfirmScreen> createState() =>
      _GrantConfirmScreenState();
}

class _GrantConfirmScreenState extends ConsumerState<GrantConfirmScreen> {
  bool _authenticating = false;
  bool _broadcasting = false;

  Future<void> _authenticate() async {
    setState(() => _authenticating = true);
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);

    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final success = await auth.authenticateBiometric();
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

    await ref.read(grantProvider.notifier).grantPermissions(
          walletId: wallet.id,
          fromAddress: wallet.address,
          granteeAddress: widget.granteeAddress,
        );

    if (!mounted) return;
    final state = ref.read(grantProvider);
    final result = state.lastTxResult;

    context.push('/miners/grant/result', extra: {
      'success': result != null && result.isSuccess,
      'txhash': result?.txhash ?? '',
      'error': state.error ?? result?.rawLog ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(activeWalletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Grant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/miners/grant');
            }
          },
        ),
      ),
      body: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Action', style: Theme.of(context).textTheme.bodySmall),
            Text('Grant ML Permissions',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text('Granter', style: Theme.of(context).textTheme.bodySmall),
            if (wallet != null) AddressDisplay(address: wallet.address),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text('Grantee', style: Theme.of(context).textTheme.bodySmall),
            AddressDisplay(address: widget.granteeAddress, compact: false),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text('Expiration', style: Theme.of(context).textTheme.bodySmall),
            Text('2 years', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text('Permissions', style: Theme.of(context).textTheme.bodySmall),
            Text('27 ML operations',
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
                      ? 'Authenticating...'
                      : 'Confirm & Grant'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
