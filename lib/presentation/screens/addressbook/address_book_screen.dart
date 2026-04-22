import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/crypto/address_service.dart';
import '../../../data/models/address_book_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/address_book_provider.dart';
import '../../widgets/responsive_center.dart';

class AddressBookScreen extends ConsumerStatefulWidget {
  final String? highlightId;
  const AddressBookScreen({super.key, this.highlightId});

  @override
  ConsumerState<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends ConsumerState<AddressBookScreen> {
  String? _highlightedId;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _highlightedId = widget.highlightId;
    if (_highlightedId != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        final entries = ref.read(addressBookProvider);
        final idx = entries.indexWhere((e) => e.id == _highlightedId);
        if (idx > 0 && _scrollController.hasClients) {
          _scrollController.animateTo(
            idx * 90.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _highlightedId = null);
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(addressBookProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addressbookTitle),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref, l10n),
        child: const Icon(Icons.add),
      ),
      body: ResponsiveCenter(
        child: entries.isEmpty
            ? _empty(context, ref, l10n)
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (_, i) =>
                    _entryCard(context, ref, entries[i], l10n),
              ),
      ),
    );
  }

  Widget _empty(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.contacts_outlined,
              size: 48, color: GonkaColors.textMuted),
          const SizedBox(height: 12),
          Text(l10n.addressbookEmpty,
              style: const TextStyle(color: GonkaColors.textMuted)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showAddDialog(context, ref, l10n),
            icon: const Icon(Icons.add),
            label: Text(l10n.addressbookAdd),
          ),
        ],
      ),
    );
  }

  Widget _entryCard(BuildContext context, WidgetRef ref,
      AddressBookEntry entry, AppLocalizations l10n) {
    final shortAddr = entry.address.length > 20
        ? '${entry.address.substring(0, 10)}...${entry.address.substring(entry.address.length - 6)}'
        : entry.address;

    final isHighlighted = entry.id == _highlightedId;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? GonkaColors.accentBlue.withValues(alpha: 0.08)
            : GonkaColors.bgCard,
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        border: Border.all(
          color: isHighlighted
              ? GonkaColors.accentBlue.withValues(alpha: 0.5)
              : GonkaColors.borderSubtle,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showContactDetail(context, ref, entry, l10n),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GonkaColors.accentBlue.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.person,
                        color: GonkaColors.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.name,
                            style: const TextStyle(
                                color: GonkaColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(shortAddr,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: GonkaColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: GonkaColors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDetail(BuildContext context, WidgetRef ref,
      AddressBookEntry entry, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => _ContactDetailDialog(
        entry: entry,
        l10n: l10n,
        onSaveName: (newName) {
          ref.read(addressBookProvider.notifier).rename(entry.id, newName);
        },
        onDelete: () {
          Navigator.pop(ctx);
          _confirmDelete(context, ref, entry, l10n);
        },
        onCopy: () {
          Clipboard.setData(ClipboardData(text: entry.address));
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.widgetAddressCopied)),
          );
        },
      ),
    );
  }

  void _showAddDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => _AddAddressDialog(l10n: l10n, ref: ref),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref,
      AddressBookEntry entry, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addressbookDelete),
        content: Text(l10n.addressbookDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GonkaColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.addressbookDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(addressBookProvider.notifier).delete(entry.id);
    }
  }
}

class _ContactDetailDialog extends StatefulWidget {
  final AddressBookEntry entry;
  final AppLocalizations l10n;
  final ValueChanged<String> onSaveName;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _ContactDetailDialog({
    required this.entry,
    required this.l10n,
    required this.onSaveName,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  State<_ContactDetailDialog> createState() => _ContactDetailDialogState();
}

class _ContactDetailDialogState extends State<_ContactDetailDialog> {
  late final TextEditingController _nameController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && name != widget.entry.name) {
      widget.onSaveName(name);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GonkaColors.accentBlue.withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.person,
                  color: GonkaColors.accentBlue, size: 32),
            ),
            const SizedBox(height: 16),

            if (_editing)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: GonkaColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        labelText: l10n.addressbookNameLabel,
                      ),
                      onSubmitted: (_) => _saveName(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _saveName,
                    icon: const Icon(Icons.check,
                        color: GonkaColors.success, size: 22),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _nameController.text.trim().isEmpty
                          ? widget.entry.name
                          : _nameController.text.trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: GonkaColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _editing = true),
                    child: const Icon(Icons.edit,
                        size: 16, color: GonkaColors.textMuted),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GonkaColors.bgSecondary,
                borderRadius: BorderRadius.circular(GonkaRadius.sm),
                border: Border.all(
                    color: GonkaColors.borderSubtle, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.entry.address,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: GonkaColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onCopy,
                    child: const Icon(Icons.copy,
                        size: 18, color: GonkaColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(l10n.addressbookDelete),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: GonkaColors.error,
                  side: const BorderSide(color: GonkaColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;
  const _AddAddressDialog({required this.l10n, required this.ref});

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final l10n = widget.l10n;

    if (name.isEmpty || address.isEmpty) return;

    if (!AddressService.validate(address)) {
      setState(() => _error = l10n.addressbookInvalidAddress);
      return;
    }
    if (widget.ref.read(addressBookProvider.notifier).containsAddress(address)) {
      setState(() => _error = l10n.addressbookDuplicate);
      return;
    }

    widget.ref.read(addressBookProvider.notifier).add(name, address);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.addressbookAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.addressbookNameLabel,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.addressbookAddressLabel,
              hintText: 'gonka1...',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.addressbookSave),
        ),
      ],
    );
  }
}
