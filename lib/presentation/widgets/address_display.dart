import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';

class AddressDisplay extends StatelessWidget {
  final String address;
  final bool compact;

  const AddressDisplay({
    super.key,
    required this.address,
    this.compact = true,
  });

  String get displayAddress {
    if (!compact || address.length < 20) return address;
    return '${address.substring(0, 12)}...${address.substring(address.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _copyToClipboard(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              displayAddress,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.copy, size: 16),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.widgetAddressCopied),
        duration: const Duration(seconds: 2),
      ),
    );
    Timer(Duration(seconds: GonkaConstants.clipboardClearSeconds), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }
}
