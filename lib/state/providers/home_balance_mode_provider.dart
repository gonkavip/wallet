import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/balance_display_mode.dart';

final homeBalanceModeProvider =
    StateProvider<BalanceDisplayMode>((ref) => BalanceDisplayMode.gnk);
