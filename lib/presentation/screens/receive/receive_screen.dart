import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/address_display.dart';
import '../../widgets/qr_code_widget.dart';
import '../../widgets/responsive_center.dart';

class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wallet = ref.watch(activeWalletProvider);

    if (wallet == null) {
      return Scaffold(body: Center(child: Text(l10n.receiveNoWallet)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiveTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                wallet.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: GonkaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GonkaRadius.lg),
                  border: Border.all(
                      color: GonkaColors.accentBlue.withValues(alpha: 0.3),
                      width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x403B82F6),
                      blurRadius: 32,
                      spreadRadius: 0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: QrCodeWidget(data: wallet.address, size: 220),
              ),
              const SizedBox(height: 28),
              AddressDisplay(address: wallet.address, compact: false),
              const SizedBox(height: 10),
              Text(
                l10n.receiveTapToCopy,
                style: const TextStyle(
                  color: GonkaColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
