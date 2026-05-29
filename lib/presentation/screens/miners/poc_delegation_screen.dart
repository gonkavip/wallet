import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/crypto/address_service.dart';
import '../../../core/platform_util.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/poc_delegation_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

enum _AddrErr { empty, invalid, self }

class PocDelegationScreen extends ConsumerStatefulWidget {
  const PocDelegationScreen({super.key});

  @override
  ConsumerState<PocDelegationScreen> createState() =>
      _PocDelegationScreenState();
}

class _PocDelegationScreenState extends ConsumerState<PocDelegationScreen> {
  final _addressController = TextEditingController();
  String? _selectedModel;
  _AddrErr? _addressErr;
  bool _modelErr = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pocDelegationProvider.notifier).loadModels();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _scanQr() async {
    if (PlatformUtil.isDesktop) {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        _addressController.text = data.text!.trim();
      }
      return;
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _QrScanPage()),
    );
    if (result != null) {
      _addressController.text = result;
    }
  }

  _AddrErr? _validateAddress(String address) {
    if (address.isEmpty) return _AddrErr.empty;
    if (!AddressService.validate(address)) return _AddrErr.invalid;
    final wallet = ref.read(activeWalletProvider);
    if (wallet != null && address == wallet.address) {
      return _AddrErr.self;
    }
    return null;
  }

  String? _errorText(AppLocalizations l10n) {
    final e = _addressErr;
    if (e == null) return null;
    return switch (e) {
      _AddrErr.empty => l10n.grantErrorEnterAddress,
      _AddrErr.invalid => l10n.grantErrorInvalidAddress,
      _AddrErr.self => l10n.grantErrorSelf,
    };
  }

  void _delegate() {
    final modelMissing = _selectedModel == null;
    final addrErr = _validateAddress(_addressController.text.trim());
    setState(() {
      _modelErr = modelMissing;
      _addressErr = addrErr;
    });
    if (modelMissing || addrErr != null) return;

    context.push('/miners/poc-delegation/confirm', extra: {
      'modelId': _selectedModel!,
      'delegateTo': _addressController.text.trim(),
    });
  }

  void _clear() {
    final modelMissing = _selectedModel == null;
    setState(() => _modelErr = modelMissing);
    if (modelMissing) return;

    context.push('/miners/poc-delegation/confirm', extra: {
      'modelId': _selectedModel!,
      'delegateTo': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(pocDelegationProvider);
    final wallet = ref.watch(activeWalletProvider);
    final senderIsParticipant = wallet == null
        ? const AsyncValue<bool?>.data(null)
        : ref.watch(isParticipantProvider(wallet.address));

    final senderBlocked = senderIsParticipant.maybeWhen(
      data: (v) => v == false,
      orElse: () => false,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l10n.pocDelegationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/miners');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.pocDelegationInfo,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (senderBlocked) ...[
                const SizedBox(height: 16),
                InfoBanner(
                  variant: InfoBannerVariant.warning,
                  message: l10n.pocDelegationSenderNotParticipant,
                ),
              ],
              const SizedBox(height: 24),
              if (state.modelsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.models.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.pocDelegationModelsError,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(pocDelegationProvider.notifier)
                            .loadModels(),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedModel,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.pocDelegationModelLabel,
                    hintText: l10n.pocDelegationModelHint,
                    errorText: _modelErr ? l10n.pocDelegationModelError : null,
                    border: const OutlineInputBorder(),
                  ),
                  items: state.models
                      .map((m) => DropdownMenuItem<String>(
                            value: m,
                            child: Text(m, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedModel = v;
                    _modelErr = false;
                  }),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.pocDelegationAddressLabel,
                  hintText: l10n.pocDelegationAddressHint,
                  errorText: _errorText(l10n),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(PlatformUtil.isDesktop
                        ? Icons.content_paste
                        : Icons.qr_code_scanner),
                    onPressed: _scanQr,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: senderBlocked ? null : _delegate,
                  child: Text(l10n.pocDelegationDelegate),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: senderBlocked ? null : _clear,
                  child: Text(l10n.pocDelegationClear),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrScanPage extends StatefulWidget {
  const _QrScanPage();

  @override
  State<_QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<_QrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _returned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).grantScanQr)),
      body: MobileScanner(
        controller: _controller,
        onDetect: (BarcodeCapture capture) {
          if (_returned) return;
          final value = capture.barcodes.firstOrNull?.rawValue;
          if (value != null && value.isNotEmpty) {
            _returned = true;
            Navigator.pop(context, value);
          }
        },
      ),
    );
  }
}
