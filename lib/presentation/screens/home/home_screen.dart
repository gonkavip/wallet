import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../config/design_tokens.dart';
import '../../../data/models/balance_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/node_provider.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wallets = ref.watch(walletsProvider);
    final nodeState = ref.watch(nodesProvider);
    final activeNode = nodeState.activeNode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ResponsiveCenter(child: wallets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 64, color: GonkaColors.textMuted),
                  const SizedBox(height: 16),
                  Text(l10n.homeEmpty,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/onboarding/create'),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.homeCreateWallet),
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
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
                children: [
                  if (activeNode != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push('/settings/nodes'),
                        borderRadius: BorderRadius.circular(GonkaRadius.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: GonkaColors.bgCard,
                            borderRadius:
                                BorderRadius.circular(GonkaRadius.md),
                            border: Border.all(
                                color: GonkaColors.borderSubtle, width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: activeNode.isHealthy
                                      ? GonkaColors.success
                                      : activeNode.isOnline
                                          ? GonkaColors.warning
                                          : GonkaColors.error,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (activeNode.isHealthy
                                              ? GonkaColors.success
                                              : activeNode.isOnline
                                                  ? GonkaColors.warning
                                                  : GonkaColors.error)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(activeNode.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: GonkaColors.textPrimary,
                                          fontWeight: FontWeight.w500)),
                              const Spacer(),
                              if (activeNode.isHealthy)
                                Text('${activeNode.latencyMs}ms',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: GonkaColors.textMuted)),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  size: 16, color: GonkaColors.textMuted),
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
                    label: Text(l10n.homeAddWallet),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            )),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GonkaRadius.lg),
          splashColor: Colors.white.withValues(alpha: 0.06),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GonkaRadius.lg),
              gradient: GonkaGradients.walletCard,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x263B82F6),
                  blurRadius: 16,
                  spreadRadius: -4,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GonkaRadius.lg),
              child: CustomPaint(
                painter: const WalletCardDotTexture(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.white.withValues(alpha: 0.8), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2)),
                    ),
                    Icon(Icons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.6), size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${address.substring(0, 12)}...${address.substring(address.length - 6)}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontFamily: 'monospace',
                      fontSize: 12,
                      letterSpacing: 0.3),
                ),
                const SizedBox(height: 18),
                balanceAsync.when(
                  data: (balance) => Text(
                    '${formatGnkShort(balance.total)} GNK',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5),
                  ),
                  loading: () => SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  error: (_, __) => Text('--',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 26)),
                ),
              ],
            ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
