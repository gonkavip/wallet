import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../../data/models/address_book_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/address_book_provider.dart';

Future<AddressBookEntry?> showAddressBookPicker(BuildContext context) {
  return showModalBottomSheet<AddressBookEntry>(
    context: context,
    constraints: const BoxConstraints(maxWidth: 600),
    isScrollControlled: true,
    builder: (_) => const _AddressBookPickerSheet(),
  );
}

class _AddressBookPickerSheet extends ConsumerWidget {
  const _AddressBookPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(addressBookProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(l10n.addressbookSelectTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            if (entries.isEmpty)
              Expanded(
                child: Center(
                  child: Text(l10n.addressbookEmpty,
                      style: const TextStyle(color: GonkaColors.textMuted)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final entry = entries[i];
                    final shortAddr = entry.address.length > 20
                        ? '${entry.address.substring(0, 10)}...${entry.address.substring(entry.address.length - 6)}'
                        : entry.address;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            GonkaColors.accentBlue.withValues(alpha: 0.12),
                        child: const Icon(Icons.person,
                            color: GonkaColors.accentBlue, size: 20),
                      ),
                      title: Text(entry.name,
                          style: const TextStyle(
                              color: GonkaColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(shortAddr,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: GonkaColors.textMuted)),
                      onTap: () => Navigator.pop(context, entry),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
