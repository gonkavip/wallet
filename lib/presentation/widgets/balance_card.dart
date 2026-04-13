import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';
import '../../data/models/balance_model.dart';
import '../../l10n/app_localizations.dart';
import 'amount_display.dart';
import 'gonka_widgets.dart';

class BalanceCard extends StatelessWidget {
  final BalanceModel balance;
  final bool useGnk;

  const BalanceCard({
    super.key,
    required this.balance,
    this.useGnk = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GonkaRadius.lg),
        gradient: GonkaGradients.walletCard,
        boxShadow: GonkaShadows.glowBlue,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GonkaRadius.lg),
        child: CustomPaint(
          painter: const WalletCardDotTexture(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.balanceTotal,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 8),
          AmountDisplay(
            amountNgonka: balance.total,
            useGnk: useGnk,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.balanceAvailable,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color:
                                    Colors.white.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                    ),
                    const SizedBox(height: 4),
                    AmountDisplay(
                      amountNgonka: balance.spendable,
                      useGnk: useGnk,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.balanceVesting,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                      ),
                      const SizedBox(height: 4),
                      AmountDisplay(
                        amountNgonka: balance.vesting,
                        useGnk: useGnk,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

