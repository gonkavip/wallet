import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/balance_model.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/node_provider.dart';
import '../../../config/constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final nodeState = ref.watch(nodesProvider);
    final activeNode = nodeState.activeNode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gonka Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: wallets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No wallets yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/onboarding/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Wallet'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                for (final w in wallets) {
                  ref.invalidate(walletBalanceProvider(w.address));
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (activeNode != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push('/settings/nodes'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.circle,
                                  size: 8,
                                  color: activeNode.isHealthy
                                      ? Colors.green
                                      : activeNode.isOnline
                                          ? Colors.orange
                                          : Colors.red),
                              const SizedBox(width: 8),
                              Text(activeNode.label,
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                              const Spacer(),
                              if (activeNode.isHealthy)
                                Text('${activeNode.latencyMs}ms',
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right,
                                  size: 16, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ...wallets.map((wallet) => _WalletCard(
                        walletId: wallet.id,
                        name: wallet.name,
                        address: wallet.address,
                        onTap: () {
                          ref
                              .read(walletsProvider.notifier)
                              .setActive(wallet.id);
                          context.push('/wallet/${wallet.id}');
                        },
                      )),

                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/onboarding/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Wallet'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

final walletBalanceProvider =
    FutureProvider.family<BalanceModel, String>((ref, address) async {
  final nodeManager = ref.watch(nodeManagerProvider);
  final client = nodeManager.client;
  if (client == null) return BalanceModel.zero();
  try {
    final spendable = await client.getSpendableBalance(address);
    final vesting = await client.getVesting(address);
    return BalanceModel(spendable: spendable, vesting: vesting);
  } catch (_) {
    return BalanceModel.zero();
  }
});

class _WalletCard extends ConsumerWidget {
  final String walletId;
  final String name;
  final String address;
  final VoidCallback onTap;

  const _WalletCard({
    required this.walletId,
    required this.name,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceProvider(address));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Colors.white54, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${address.substring(0, 12)}...${address.substring(address.length - 6)}',
                style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'monospace',
                    fontSize: 12),
              ),
              const SizedBox(height: 16),
              balanceAsync.when(
                data: (balance) => Text(
                  '${formatGnkShort(balance.total)} GNK',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                loading: () => const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white54),
                ),
                error: (_, __) => const Text('--',
                    style: TextStyle(color: Colors.white54, fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
