import 'package:flutter/material.dart';
import '../../config/constants.dart';

class AmountDisplay extends StatelessWidget {
  final BigInt amountNgonka;
  final bool showDenom;
  final bool useGnk;
  final bool exact;
  final TextStyle? style;

  const AmountDisplay({
    super.key,
    required this.amountNgonka,
    this.showDenom = true,
    this.useGnk = true,
    this.exact = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final text = useGnk
        ? (exact ? formatGnk(amountNgonka) : formatGnkShort(amountNgonka))
        : amountNgonka.toString();
    final denom = useGnk ? GonkaConstants.displayDenom : GonkaConstants.baseDenom;

    return Text(
      showDenom ? '$text $denom' : text,
      style: style ?? Theme.of(context).textTheme.headlineMedium,
    );
  }
}
