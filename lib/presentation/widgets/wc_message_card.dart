import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/design_tokens.dart';
import '../../core/walletconnect/tx_body_decoder.dart';
import '../../l10n/app_localizations.dart';

class WcMessageCard extends StatelessWidget {
  final WcMessageDescription message;

  const WcMessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isKnown && message.msgSend != null) {
      return _knownMsgSend(context);
    }
    return _unknown(context);
  }

  Widget _knownMsgSend(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final send = message.msgSend!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(context, l10n.wcMsgSendFrom, send.fromAddress, monospace: true),
          const SizedBox(height: 10),
          _row(context, l10n.wcMsgSendTo, send.toAddress, monospace: true),
          const SizedBox(height: 10),
          _row(context, l10n.wcMsgSendAmount, _formatAmounts(send.amount.map(
              (c) => _CoinLite(denom: c.denom, amount: c.amount)).toList())),
        ],
      ),
    );
  }

  Widget _unknown(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(context, warning: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: GonkaColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.wcSignUnknownMessage,
                    style: const TextStyle(color: GonkaColors.warning)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(context, l10n.wcMsgRawTypeUrl,
              message.typeUrl.isEmpty ? '—' : message.typeUrl,
              monospace: true),
          const SizedBox(height: 10),
          _row(context, l10n.wcMsgRawValueHex, message.rawValueHex,
              monospace: true, maxLines: 6),
        ],
      ),
    );
  }

  BoxDecoration _cardBox(BuildContext context, {bool warning = false}) =>
      BoxDecoration(
        color: GonkaColors.bgCard,
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        border: Border.all(
          color: warning
              ? GonkaColors.warning.withValues(alpha: 0.5)
              : GonkaColors.borderSubtle,
          width: 1,
        ),
      );

  Widget _row(BuildContext context, String label, String value,
      {bool monospace = false, int maxLines = 4}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: GonkaColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: GonkaColors.textPrimary,
            fontSize: 13,
            fontFamily: monospace ? 'monospace' : null,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatAmounts(List<_CoinLite> coins) {
    if (coins.isEmpty) return '—';
    return coins.map((c) {
      if (c.denom == 'ngonka') {
        try {
          final bi = BigInt.parse(c.amount);
          return '${formatGnk(bi)} GNK';
        } catch (_) {}
      }
      return '${c.amount} ${c.denom}';
    }).join('\n');
  }
}

class _CoinLite {
  final String denom;
  final String amount;
  _CoinLite({required this.denom, required this.amount});
}
