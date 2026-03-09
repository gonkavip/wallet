import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/crypto/mnemonic_service.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final List<TextEditingController> _controllers =
      List.generate(24, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(24, (_) => FocusNode());
  String? _error;
  bool _showSuggestions = false;
  int _activeSuggestionField = -1;
  List<String> _suggestions = [];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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
    final words = _controllers.map((c) => c.text.trim().toLowerCase()).toList();
    if (words.any((w) => w.isEmpty)) {
      setState(() => _error = 'Please fill in all 24 words');
      return;
    }
    final mnemonic = words.join(' ');
    if (!MnemonicService.validate(mnemonic)) {
      setState(() => _error = 'Invalid seed phrase');
      return;
    }
    context.push('/onboarding/name', extra: mnemonic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Wallet'),
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
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ),
          Expanded(
            child: GridView.builder(
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 10),
                    border: const OutlineInputBorder(),
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
            ),
          ),
          if (_showSuggestions)
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
              height: 56,
              child: FilledButton(
                onPressed: _validate,
                child: const Text('Import'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
