import '../l10n/app_localizations.dart';

String localizeError(AppLocalizations l10n, String? raw) {
  if (raw == null || raw.isEmpty) return l10n.errorGeneric;
  final msg = raw.replaceFirst('Exception: ', '');

  if (msg.contains('No active node')) return l10n.errorNoActiveNode;
  if (msg.contains('Mnemonic not found')) return l10n.errorMnemonicNotFound;
  if (msg.contains('Invalid mnemonic')) return l10n.errorInvalidMnemonic;

  return msg;
}
