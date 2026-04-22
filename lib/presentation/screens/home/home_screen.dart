import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../config/design_tokens.dart';
import '../../../core/crypto/address_service.dart';
import '../../../core/platform_util.dart';
import '../../../data/models/balance_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/address_book_provider.dart';
import '../../../state/providers/home_balance_mode_provider.dart';
import '../../../state/providers/market_price_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/node_provider.dart';
import '../../../state/providers/wc_connect_provider.dart';
import '../../widgets/balance_display_mode.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';
import '../walletconnect/wc_qr_scan_page.dart';

void _showAddContactDialog(
    BuildContext context, WidgetRef ref, AppLocalizations l10n, String address) {
  final book = ref.read(addressBookProvider.notifier);
  if (book.containsAddress(address)) {
    final entry = ref.read(addressBookProvider).firstWhere(
        (e) => e.address == address);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${entry.name} — ${l10n.addressbookDuplicate}')),
    );
    return;
  }
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.addressbookAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            address,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: GonkaColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.addressbookNameLabel,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              ref.read(addressBookProvider.notifier).add(name, address);
              Navigator.pop(ctx);
            }
          },
          child: Text(l10n.addressbookSave),
        ),
      ],
    ),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wallets = ref.watch(walletsProvider);
    final nodeState = ref.watch(nodesProvider);
    final activeNode = nodeState.activeNode;

    final mode = ref.watch(homeBalanceModeProvider);

    IconData modeIcon;
    switch (mode) {
      case BalanceDisplayMode.gnk:
        modeIcon = Icons.attach_money;
        break;
      case BalanceDisplayMode.ngonka:
        modeIcon = Icons.toll;
        break;
      case BalanceDisplayMode.usd:
        modeIcon = Icons.currency_exchange;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        leadingWidth: 96,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
            if (PlatformUtil.isDesktop) {
              context.push('/wc/connect');
              return;
            }
            final result = await Navigator.of(context).push<String>(
              MaterialPageRoute(builder: (_) => const WcQrScanPage()),
            );
            if (result == null || result.isEmpty || !context.mounted) return;
            final trimmed = result.trim();

            if (AddressService.validate(trimmed)) {
              _showAddContactDialog(context, ref, l10n, trimmed);
              return;
            }

            if (trimmed.startsWith('wc:')) {
              if (wallets.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.wcErrorNoWallets)),
                );
                return;
              }
              try {
                await ref.read(wcConnectProvider.notifier).pair(trimmed);
              } on WcConnectError catch (e) {
                if (!context.mounted) return;
                final msg = switch (e.code) {
                  'invalidUri' => l10n.wcConnectInvalidUri,
                  'expiredUri' => l10n.wcConnectExpiredUri,
                  'noWallets' => l10n.wcErrorNoWallets,
                  _ => l10n.wcErrorGeneric(e.code),
                };
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.wcErrorGeneric('$e'))),
                );
              }
              return;
            }

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.scanUnrecognized)),
            );
          },
            ),
            IconButton(
              icon: Icon(modeIcon),
              tooltip: l10n.balanceTotal,
              onPressed: () {
                final usdPrice =
                    ref.read(marketPriceProvider).valueOrNull;
                final current = ref.read(homeBalanceModeProvider);
                BalanceDisplayMode next;
                switch (current) {
                  case BalanceDisplayMode.gnk:
                    next = BalanceDisplayMode.ngonka;
                    break;
                  case BalanceDisplayMode.ngonka:
                    next = usdPrice != null
                        ? BalanceDisplayMode.usd
                        : BalanceDisplayMode.gnk;
                    break;
                  case BalanceDisplayMode.usd:
                    next = BalanceDisplayMode.gnk;
                    break;
                }
                ref.read(homeBalanceModeProvider.notifier).state = next;
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts_outlined),
            tooltip: l10n.addressbookTitle,
            onPressed: () => context.push('/addressbook'),
          ),
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

  String _formatBalance(
      BalanceDisplayMode mode, BigInt total, double? usdPrice) {
    switch (mode) {
      case BalanceDisplayMode.gnk:
        return '${formatGnkShort(total)} GNK';
      case BalanceDisplayMode.ngonka:
        return '${formatNgonka(total)} ${GonkaConstants.baseDenom}';
      case BalanceDisplayMode.usd:
        if (usdPrice == null) return '${formatGnkShort(total)} GNK';
        return formatUsd(total, usdPrice);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceProvider(address));
    final mode = ref.watch(homeBalanceModeProvider);
    final usdPrice = ref.watch(marketPriceProvider).valueOrNull;
    final effectiveMode =
        (mode == BalanceDisplayMode.usd && usdPrice == null)
            ? BalanceDisplayMode.gnk
            : mode;

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
                    _formatBalance(effectiveMode, balance.total, usdPrice),
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
