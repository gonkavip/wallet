import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/crypto/address_service.dart';
import '../../../state/providers/unjail_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
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
        title: const Text('Unjail Validator'),
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
      body: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: _done
            ? _buildResult(context)
            : _buildConfirm(context, wallet, valoperAddr),
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
    final bool canUnjail = jailed == true;

    final Color infoColor;
    final IconData infoIcon;
    final String infoText;

    if (jailed == true) {
      infoColor = Colors.amber;
      infoIcon = Icons.warning_outlined;
      infoText =
          'Your validator is jailed. Send an unjail transaction to resume operations.';
    } else if (jailed == false) {
      infoColor = Colors.green;
      infoIcon = Icons.check_circle_outline;
      infoText = 'Your validator is not jailed. No action needed.';
    } else {
      infoColor = Colors.grey;
      infoIcon = Icons.help_outline;
      infoText =
          'Validator not found on chain. Make sure your validator has been created.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: infoColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(infoIcon, color: infoColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(infoText, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Action', style: Theme.of(context).textTheme.bodySmall),
        Text('Unjail Validator',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        Text('Validator Address',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          valoperAddr,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        Text('Fee', style: Theme.of(context).textTheme.bodySmall),
        Text('0 GNK', style: Theme.of(context).textTheme.titleMedium),

        const Spacer(),

        if (_broadcasting)
          const Center(child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed:
                  canUnjail && !_authenticating ? _authenticate : null,
              child: Text(_authenticating
                  ? 'Authenticating...'
                  : 'Confirm & Unjail'),
            ),
          ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Icon(
          _success ? Icons.check_circle : Icons.error,
          size: 80,
          color: _success ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 24),
        Text(
          _success ? 'Unjail Successful' : 'Unjail Failed',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        if (_success && _txhash.isNotEmpty) ...[
          Text('Transaction Hash',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _txhash));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hash copied to clipboard')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _txhash,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        if (!_success && _error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _error,
            style: TextStyle(color: Colors.red[300], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/miners');
              }
            },
            child: const Text('Done'),
          ),
        ),
        if (!_success) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ),
        ],
      ],
    );
  }
}
