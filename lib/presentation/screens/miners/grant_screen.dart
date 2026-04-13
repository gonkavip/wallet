import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/crypto/address_service.dart';
import '../../../core/platform_util.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

enum _GrantAddrErr { empty, invalid, self }

class GrantScreen extends ConsumerStatefulWidget {
  const GrantScreen({super.key});

  @override
  ConsumerState<GrantScreen> createState() => _GrantScreenState();
}

class _GrantScreenState extends ConsumerState<GrantScreen> {
  final _addressController = TextEditingController();
  _GrantAddrErr? _addressErr;

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

  _GrantAddrErr? _validateAddress(String address) {
    if (address.isEmpty) return _GrantAddrErr.empty;
    if (!AddressService.validate(address)) return _GrantAddrErr.invalid;
    final wallet = ref.read(activeWalletProvider);
    if (wallet != null && address == wallet.address) {
      return _GrantAddrErr.self;
    }
    return null;
  }

  String? _errorText(AppLocalizations l10n) {
    final e = _addressErr;
    if (e == null) return null;
    return switch (e) {
      _GrantAddrErr.empty => l10n.grantErrorEnterAddress,
      _GrantAddrErr.invalid => l10n.grantErrorInvalidAddress,
      _GrantAddrErr.self => l10n.grantErrorSelf,
    };
  }

  void _continue() {
    final addrErr = _validateAddress(_addressController.text.trim());
    setState(() => _addressErr = addrErr);
    if (addrErr != null) return;

    context.push('/miners/grant/confirm', extra: {
      'granteeAddress': _addressController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.grantTitle),
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
                        l10n.grantInfo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.grantOpKeyLabel,
                hintText: l10n.grantOpKeyHint,
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
                onPressed: _continue,
                child: Text(l10n.grantContinue),
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
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).grantScanQr)),
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
