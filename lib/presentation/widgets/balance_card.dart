import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/design_tokens.dart';
import '../../data/models/balance_model.dart';
import '../../l10n/app_localizations.dart';
import 'amount_display.dart';
import 'balance_display_mode.dart';
import 'gonka_widgets.dart';

class BalanceCard extends StatelessWidget {
  final BalanceModel balance;
  final BalanceDisplayMode mode;
  final double? usdPrice;

  const BalanceCard({
    super.key,
    required this.balance,
    this.mode = BalanceDisplayMode.gnk,
    this.usdPrice,
  });

  bool get _useGnk => mode == BalanceDisplayMode.gnk;
  bool get _isUsd => mode == BalanceDisplayMode.usd;

  Widget _amount(BuildContext context, BigInt ngonka, TextStyle? style) {
    if (_isUsd && usdPrice != null) {
      return Text(formatUsd(ngonka, usdPrice!), style: style);
    }
    return AmountDisplay(
      amountNgonka: ngonka,
      useGnk: _useGnk,
      style: style,
    );
  }

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
          _amount(
            context,
            balance.total,
            Theme.of(context).textTheme.headlineLarge?.copyWith(
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
                    _amount(
                      context,
                      balance.spendable,
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
                      _amount(
                        context,
                        balance.vesting,
                        Theme.of(context)
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

