import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/amount_input_formatter.dart';
import '../../../config/constants.dart';
import '../../../config/design_tokens.dart';
import '../../../core/platform_util.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/balance_provider.dart';
import '../../../state/providers/collateral_provider.dart';
import '../../widgets/responsive_center.dart';

enum _CollateralAmountErr { empty, notPositive, insufficient, exceeds, invalid }

class CollateralAmountScreen extends ConsumerStatefulWidget {
  final bool isDeposit;

  const CollateralAmountScreen({super.key, required this.isDeposit});

  @override
  ConsumerState<CollateralAmountScreen> createState() =>
      _CollateralAmountScreenState();
}

class _CollateralAmountScreenState
    extends ConsumerState<CollateralAmountScreen> {
  final _amountController = TextEditingController();
  bool _useGnk = true;
  _CollateralAmountErr? _amountErr;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _switchDenom(bool toGnk) {
    if (toGnk == _useGnk) return;
    final input = _amountController.text.trim();
    if (input.isNotEmpty) {
      try {
        if (toGnk) {
          final ngonka = BigInt.parse(input.replaceAll(',', ''));
          _amountController.text = formatGnk(ngonka);
        } else {
          final ngonka = parseGnk(input);
          _amountController.text = formatNgonka(ngonka);
        }
      } catch (_) {}
    }
    setState(() => _useGnk = toGnk);
  }

  void _setMax() {
    if (widget.isDeposit) {
      final balanceAsync = ref.read(balanceProvider);
      balanceAsync.whenData((balance) {
        if (_useGnk) {
          _amountController.text = formatGnk(balance.spendable);
        } else {
          _amountController.text = formatNgonka(balance.spendable);
        }
      });
    } else {
      final collateralState = ref.read(collateralProvider);
      final current = collateralState.collateral;
      if (_useGnk) {
        _amountController.text = formatGnk(current);
      } else {
        _amountController.text = formatNgonka(current);
      }
    }
  }

  _CollateralAmountErr? _validateAmount(String input) {
    if (input.isEmpty) return _CollateralAmountErr.empty;
    try {
      final ngonka = _useGnk
          ? parseGnk(input)
          : BigInt.parse(input.replaceAll(',', ''));
      if (ngonka <= BigInt.zero) return _CollateralAmountErr.notPositive;
      if (widget.isDeposit) {
        final balanceAsync = ref.read(balanceProvider);
        return balanceAsync.whenOrNull(data: (balance) {
          if (ngonka > balance.spendable) {
            return _CollateralAmountErr.insufficient;
          }
          return null;
        });
      } else {
        final collateralState = ref.read(collateralProvider);
        if (ngonka > collateralState.collateral) {
          return _CollateralAmountErr.exceeds;
        }
      }
      return null;
    } catch (_) {
      return _CollateralAmountErr.invalid;
    }
  }

  String? _errorText(AppLocalizations l10n) {
    final e = _amountErr;
    if (e == null) return null;
    return switch (e) {
      _CollateralAmountErr.empty => l10n.sendErrorEnterAmount,
      _CollateralAmountErr.notPositive => l10n.sendErrorAmountPositive,
      _CollateralAmountErr.insufficient => l10n.sendErrorInsufficient,
      _CollateralAmountErr.exceeds => l10n.collateralErrorExceeds,
      _CollateralAmountErr.invalid => l10n.sendErrorInvalidAmount,
    };
  }

  void _continue() {
    final amtErr = _validateAmount(_amountController.text.trim());
    setState(() => _amountErr = amtErr);
    if (amtErr != null) return;

    final ngonka = _useGnk
        ? parseGnk(_amountController.text.trim())
        : BigInt.parse(_amountController.text.trim().replaceAll(',', ''));

    context.push('/miners/collateral/confirm', extra: {
      'amountNgonka': ngonka.toString(),
      'isDeposit': widget.isDeposit,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.isDeposit
        ? l10n.collateralDepositTitle
        : l10n.collateralWithdrawTitle;
    final collateralState = ref.watch(collateralProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/miners/collateral');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isDeposit) ...[
              Text(
                l10n.collateralCurrentInfo(
                    formatGnk(collateralState.collateral)),
                style: const TextStyle(
                  color: GonkaColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: PlatformUtil.isDesktop
                        ? null
                        : const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [commaToDotInsertedFormatter],
                    decoration: InputDecoration(
                      labelText: l10n.sendAmountLabel,
                      errorText: _errorText(l10n),
                      suffixText: _useGnk
                          ? GonkaConstants.displayDenom
                          : GonkaConstants.baseDenom,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _setMax,
                  child: Text(l10n.sendMaxButton),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.sendUnitGnk),
                  selected: _useGnk,
                  onSelected: (_) => _switchDenom(true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.sendUnitNgonka),
                  selected: !_useGnk,
                  onSelected: (_) => _switchDenom(false),
                ),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continue,
                child: Text(l10n.sendContinue),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
