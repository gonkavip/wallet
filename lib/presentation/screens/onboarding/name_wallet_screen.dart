import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/responsive_center.dart';

class NameWalletScreen extends ConsumerStatefulWidget {
  final String mnemonic;

  const NameWalletScreen({super.key, required this.mnemonic});

  @override
  ConsumerState<NameWalletScreen> createState() => _NameWalletScreenState();
}

class _NameWalletScreenState extends ConsumerState<NameWalletScreen> {
  final _controller = TextEditingController(text: 'My Wallet');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Name Your Wallet')),
      body: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Give your wallet a name',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'This is just for your reference.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Wallet Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.push(
                        '/onboarding/pin',
                        extra: {
                          'mnemonic': widget.mnemonic,
                          'name': _controller.text.trim(),
                        },
                      );
                    }
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
