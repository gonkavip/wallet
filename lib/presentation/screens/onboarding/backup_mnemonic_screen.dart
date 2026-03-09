import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/crypto/mnemonic_service.dart';
import '../../../data/services/device_security_service.dart';

final _tempMnemonicProvider = StateProvider<String>((ref) => '');

class BackupMnemonicScreen extends ConsumerStatefulWidget {
  const BackupMnemonicScreen({super.key});

  @override
  ConsumerState<BackupMnemonicScreen> createState() =>
      _BackupMnemonicScreenState();
}

class _BackupMnemonicScreenState extends ConsumerState<BackupMnemonicScreen> {
  late String _mnemonic;
  late List<String> _words;
  bool _confirmed = false;
  bool _verifying = false;
  int _verifyIndex = 0;
  final _verifyController = TextEditingController();
  String? _verifyError;

  @override
  void initState() {
    super.initState();
    _mnemonic = MnemonicService.generate();
    _words = _mnemonic.split(' ');
    DeviceSecurityService.enableSecureScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_tempMnemonicProvider.notifier).state = _mnemonic;
    });
  }

  @override
  void dispose() {
    DeviceSecurityService.disableSecureScreen();
    _verifyController.dispose();
    super.dispose();
  }

  void _startVerification() {
    setState(() {
      _verifying = true;
      _verifyIndex = Random.secure().nextInt(_words.length);
      _verifyController.clear();
      _verifyError = null;
    });
  }

  void _checkVerification() {
    if (_verifyController.text.trim().toLowerCase() ==
        _words[_verifyIndex].toLowerCase()) {
      context.push('/onboarding/name', extra: _mnemonic);
    } else {
      setState(() {
        _verifyError = 'Incorrect word. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verifying) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verify Backup')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is word #${_verifyIndex + 1}?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _verifyController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Enter word #${_verifyIndex + 1}',
                  errorText: _verifyError,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _checkVerification(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _checkVerification,
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Back Up Seed Phrase'),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Write down these 24 words in order. Never share them. Anyone with this phrase can access your funds.',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _words[index],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!_confirmed) ...[
              CheckboxListTile(
                value: false,
                onChanged: (v) {
                  if (v == true) {
                    setState(() => _confirmed = true);
                  }
                },
                title: const Text('I have written down the seed phrase'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
            if (_confirmed)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _startVerification,
                  child: const Text('Continue'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
