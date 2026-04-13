import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/crypto/hd_key_service.dart';
import '../../../core/crypto/mnemonic_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';
import 'onboarding_secret.dart';

enum _ImportError { wordCount, fillAll, invalid, invalidPrivateKey }

enum _ImportMode { wordByWord, paste, privateKey }

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final List<TextEditingController> _controllers =
      List.generate(24, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(24, (_) => FocusNode());
  final TextEditingController _pasteController = TextEditingController();
  final TextEditingController _pkController = TextEditingController();
  _ImportError? _error;
  int _wordCount = 0;
  bool _showSuggestions = false;
  int _activeSuggestionField = -1;
  List<String> _suggestions = [];
  _ImportMode _mode = _ImportMode.wordByWord;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _pasteController.dispose();
    _pkController.dispose();
    super.dispose();
  }

  void _updateSuggestions(int index, String value) {
    if (value.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }
    final words = MnemonicService.wordList
        .where((w) => w.startsWith(value.toLowerCase()))
        .take(5)
        .toList();
    setState(() {
      _activeSuggestionField = index;
      _suggestions = words;
      _showSuggestions = words.isNotEmpty;
    });
  }

  void _selectSuggestion(String word) {
    if (_activeSuggestionField >= 0) {
      _controllers[_activeSuggestionField].text = word;
      setState(() => _showSuggestions = false);
      if (_activeSuggestionField < 23) {
        _focusNodes[_activeSuggestionField + 1].requestFocus();
      }
    }
  }

  void _validate() {
    if (_mode == _ImportMode.privateKey) {
      final raw = _pkController.text;
      try {
        final cleaned = normalizePrivateKeyHex(raw);
        context.push('/onboarding/name',
            extra: OnboardingSecret.privateKey(cleaned));
      } catch (_) {
        setState(() => _error = _ImportError.invalidPrivateKey);
      }
      return;
    }
    String mnemonic;
    if (_mode == _ImportMode.paste) {
      mnemonic = _pasteController.text.trim().toLowerCase();
      final words = mnemonic.split(RegExp(r'\s+'));
      if (words.length != 24) {
        setState(() {
          _error = _ImportError.wordCount;
          _wordCount = words.length;
        });
        return;
      }
    } else {
      final words = _controllers.map((c) => c.text.trim().toLowerCase()).toList();
      if (words.any((w) => w.isEmpty)) {
        setState(() => _error = _ImportError.fillAll);
        return;
      }
      mnemonic = words.join(' ');
    }
    if (!MnemonicService.validate(mnemonic)) {
      setState(() => _error = _ImportError.invalid);
      return;
    }
    context.push('/onboarding/name',
        extra: OnboardingSecret.mnemonic(mnemonic));
  }

  String _errorMessage(AppLocalizations l10n) {
    return switch (_error!) {
      _ImportError.wordCount =>
        l10n.onboardingImportErrorWordCount(_wordCount),
      _ImportError.fillAll => l10n.onboardingImportErrorFillAll,
      _ImportError.invalid => l10n.onboardingImportErrorInvalid,
      _ImportError.invalidPrivateKey =>
        l10n.onboardingImportPrivateKeyErrorInvalid,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingImportTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding/create');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<_ImportMode>(
              segments: [
                ButtonSegment(
                  value: _ImportMode.wordByWord,
                  label: Text(l10n.onboardingImportWordByWord),
                  icon: const Icon(Icons.grid_view, size: 18),
                ),
                ButtonSegment(
                  value: _ImportMode.paste,
                  label: Text(l10n.onboardingImportPastePhrase),
                  icon: const Icon(Icons.content_paste, size: 18),
                ),
                ButtonSegment(
                  value: _ImportMode.privateKey,
                  label: Text(l10n.onboardingImportPrivateKey),
                  icon: const Icon(Icons.vpn_key_outlined, size: 18),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (v) {
                setState(() {
                  _mode = v.first;
                  _error = null;
                  _showSuggestions = false;
                });
              },
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: InfoBanner(
                variant: InfoBannerVariant.error,
                message: _errorMessage(l10n),
              ),
            ),
          Expanded(
            child: switch (_mode) {
              _ImportMode.wordByWord => _buildGridInput(),
              _ImportMode.paste => _buildPasteInput(),
              _ImportMode.privateKey => _buildPrivateKeyInput(),
            },
          ),
          if (_mode == _ImportMode.wordByWord && _showSuggestions)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _suggestions.map((word) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(word),
                      onPressed: () => _selectSuggestion(word),
                    ),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _validate,
                child: Text(l10n.onboardingImportButton),
              ),
            ),
          ),
        ],
      )),
      ),
    );
  }

  Widget _buildPasteInput() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _pasteController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: l10n.onboardingImportHint,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: _pasteController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _pasteController.clear();
                    setState(() => _error = null);
                  },
                )
              : null,
        ),
        autocorrect: false,
        enableSuggestions: false,
        onChanged: (_) => setState(() => _error = null),
      ),
    );
  }

  Widget _buildPrivateKeyInput() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _pkController,
        maxLines: 4,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        decoration: InputDecoration(
          hintText: l10n.onboardingImportPrivateKeyHint,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: _pkController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _pkController.clear();
                    setState(() => _error = null);
                  },
                )
              : null,
        ),
        autocorrect: false,
        enableSuggestions: false,
        onChanged: (_) => setState(() => _error = null),
      ),
    );
  }

  Widget _buildGridInput() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 24,
      itemBuilder: (context, index) {
        return TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          decoration: InputDecoration(
            labelText: '${index + 1}',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
          autocorrect: false,
          onChanged: (v) {
            setState(() => _error = null);
            _updateSuggestions(index, v);
            if (v.contains(' ')) {
              final words = v.trim().split(RegExp(r'\s+'));
              if (words.length >= 24) {
                for (var i = 0; i < 24; i++) {
                  _controllers[i].text = words[i];
                }
                setState(() => _showSuggestions = false);
              }
            }
          },
          onSubmitted: (_) {
            if (index < 23) {
              _focusNodes[index + 1].requestFocus();
            }
          },
          textInputAction:
              index < 23 ? TextInputAction.next : TextInputAction.done,
        );
      },
    );
  }
}
