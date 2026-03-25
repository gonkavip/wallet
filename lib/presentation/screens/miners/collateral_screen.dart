import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../state/providers/collateral_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

class CollateralScreen extends ConsumerStatefulWidget {
  const CollateralScreen({super.key});

  @override
  ConsumerState<CollateralScreen> createState() => _CollateralScreenState();
}

class _CollateralScreenState extends ConsumerState<CollateralScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollateral();
    });
  }

  void _loadCollateral() {
    final wallet = ref.read(activeWalletProvider);
    if (wallet != null) {
      ref.read(collateralProvider.notifier).load(wallet.address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collateralProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collateral'),
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
      body: ResponsiveCenter(child: RefreshIndicator(
        onRefresh: () async => _loadCollateral(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Current Collateral',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    if (state.isLoading && state.collateral == BigInt.zero)
                      const CircularProgressIndicator()
                    else
                      Text(
                        '${formatGnk(state.collateral)} GNK',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => context.push('/miners/collateral/deposit'),
                    icon: const Icon(Icons.add),
                    label: const Text('Deposit'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => context.push('/miners/collateral/withdraw'),
                    icon: const Icon(Icons.remove),
                    label: const Text('Withdraw'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (state.unbonding.isNotEmpty) ...[
              Text('Unbonding',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...state.unbonding.map((entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.orange.withValues(alpha: 0.1),
                        child: const Icon(Icons.hourglass_bottom,
                            color: Colors.orange, size: 20),
                      ),
                      title: Text('${formatGnk(entry.amount)} GNK'),
                      subtitle:
                          Text('Completion epoch: ${entry.completionEpoch}'),
                    ),
                  )),
            ],

            if (!state.isLoading &&
                state.collateral == BigInt.zero &&
                state.unbonding.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No collateral yet',
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
          ],
        ),
      )),
    );
  }
}
