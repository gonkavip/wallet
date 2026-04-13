import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../error_l10n.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

class GrantResultScreen extends StatelessWidget {
  final bool success;
  final String txhash;
  final String error;

  const GrantResultScreen({
    super.key,
    required this.success,
    this.txhash = '',
    this.error = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ResultIcon(success: success),
              const SizedBox(height: 28),
              Text(
                success ? l10n.grantResultSuccess : l10n.grantResultFailed,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: GonkaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              if (success && txhash.isNotEmpty) TxHashDisplay(hash: txhash),
              if (!success && error.isNotEmpty)
                InfoBanner(
                  variant: InfoBannerVariant.error,
                  message: localizeError(l10n, error),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.pop();
                    context.pop();
                    context.pop();
                  },
                  child: Text(l10n.commonDone),
                ),
              ),
              if (!success) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.pop();
                      context.pop();
                    },
                    child: Text(l10n.commonRetry),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
