import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../core/platform_util.dart';
import '../../../state/providers/balance_provider.dart';
import '../../../state/providers/collateral_provider.dart';
import '../../widgets/responsive_center.dart';

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
  String? _amountError;

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
          final ngonka = BigInt.parse(input);
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

  String? _validateAmount(String input) {
    if (input.isEmpty) return 'Enter amount';
    try {
      final ngonka = _useGnk ? parseGnk(input) : BigInt.parse(input.replaceAll(',', ''));
      if (ngonka <= BigInt.zero) return 'Amount must be positive';
      if (widget.isDeposit) {
        final balanceAsync = ref.read(balanceProvider);
        return balanceAsync.whenOrNull(data: (balance) {
          if (ngonka > balance.spendable) return 'Insufficient balance';
          return null;
        });
      } else {
        final collateralState = ref.read(collateralProvider);
        if (ngonka > collateralState.collateral) {
          return 'Exceeds current collateral';
        }
      }
      return null;
    } catch (_) {
      return 'Invalid amount';
    }
  }

  void _continue() {
    final amtErr = _validateAmount(_amountController.text.trim());
    setState(() => _amountError = amtErr);
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
    final title =
        widget.isDeposit ? 'Deposit Collateral' : 'Withdraw Collateral';
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
      body: ResponsiveCenter(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isDeposit) ...[
              Text(
                'Current collateral: ${formatGnk(collateralState.collateral)} GNK',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
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
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      errorText: _amountError,
                      border: const OutlineInputBorder(),
                      suffixText: _useGnk
                          ? GonkaConstants.displayDenom
                          : GonkaConstants.baseDenom,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _setMax,
                  child: const Text('MAX'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                ChoiceChip(
                  label: const Text('GNK'),
                  selected: _useGnk,
                  onSelected: (_) => _switchDenom(true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('ngonka'),
                  selected: !_useGnk,
                  onSelected: (_) => _switchDenom(false),
                ),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _continue,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
