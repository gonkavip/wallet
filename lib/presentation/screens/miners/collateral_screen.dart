import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/collateral_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/gonka_widgets.dart';
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(collateralProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collateralTitle),
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
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: GonkaGradients.walletCard,
                borderRadius: BorderRadius.circular(GonkaRadius.lg),
                boxShadow: GonkaShadows.glowBlue,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(GonkaRadius.lg),
                child: CustomPaint(
                  painter: const WalletCardDotTexture(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(l10n.collateralCurrent,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                            )),
                        const SizedBox(height: 10),
                        if (state.isLoading && state.collateral == BigInt.zero)
                          const CircularProgressIndicator(color: Colors.white)
                        else
                          Text(
                            '${formatGnk(state.collateral)} GNK',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                      ],
                    ),
                  ),
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
                    label: Text(l10n.collateralDeposit),
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
                    label: Text(l10n.collateralWithdraw),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (state.unbonding.isNotEmpty) ...[
              Text(l10n.collateralUnbonding,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GonkaColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 10),
              ...state.unbonding.map((entry) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: GonkaColors.bgCard,
                      borderRadius: BorderRadius.circular(GonkaRadius.md),
                      border: Border.all(
                          color: GonkaColors.borderSubtle, width: 1),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GonkaColors.warning.withValues(alpha: 0.12),
                          border: Border.all(
                              color: GonkaColors.warning
                                  .withValues(alpha: 0.3),
                              width: 1),
                        ),
                        child: const Icon(Icons.hourglass_bottom,
                            color: GonkaColors.warning, size: 20),
                      ),
                      title: Text('${formatGnk(entry.amount)} GNK',
                          style: const TextStyle(
                              color: GonkaColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          l10n.collateralCompletionEpoch(
                              entry.completionEpoch),
                          style: const TextStyle(
                              color: GonkaColors.textMuted, fontSize: 12)),
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
                    const Icon(Icons.shield_outlined,
                        size: 48, color: GonkaColors.textMuted),
                    const SizedBox(height: 12),
                    Text(l10n.collateralEmpty,
                        style: const TextStyle(
                            color: GonkaColors.textMuted)),
                  ],
                ),
              ),
          ],
        ),
      )),
    );
  }
}
