import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../config/constants.dart';
import '../../../core/crypto/address_service.dart';
import '../../../core/platform_util.dart';
import '../../../state/providers/balance_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _useGnk = true;
  String? _addressError;
  String? _amountError;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
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

  void _switchDenom(bool toGnk) {
    if (toGnk == _useGnk) return;
    final input = _amountController.text.trim();
    if (input.isNotEmpty) {
      try {
        if (toGnk) {
          final ngonka = BigInt.parse(input);
          _amountController.text = formatGnk(ngonka);
        } else {
          final ngonka = parseGnk(input);
          _amountController.text = formatNgonka(ngonka);
        }
      } catch (_) {}
    }
    setState(() => _useGnk = toGnk);
  }

  void _setMax() {
    final balanceAsync = ref.read(balanceProvider);
    balanceAsync.whenData((balance) {
      if (_useGnk) {
        _amountController.text = formatGnk(balance.spendable);
      } else {
        _amountController.text = formatNgonka(balance.spendable);
      }
    });
  }

  String? _validateAddress(String address) {
    if (address.isEmpty) return 'Enter recipient address';
    if (!AddressService.validate(address)) return 'Invalid Gonka address';
    final wallet = ref.read(activeWalletProvider);
    if (wallet != null && address == wallet.address) {
      return 'Cannot send to yourself';
    }
    return null;
  }

  String? _validateAmount(String input) {
    if (input.isEmpty) return 'Enter amount';
    try {
      final ngonka = _useGnk ? parseGnk(input) : BigInt.parse(input.replaceAll(',', ''));
      if (ngonka <= BigInt.zero) return 'Amount must be positive';
      final balanceAsync = ref.read(balanceProvider);
      return balanceAsync.whenOrNull(data: (balance) {
        if (ngonka > balance.spendable) return 'Insufficient balance';
        return null;
      });
    } catch (_) {
      return 'Invalid amount';
    }
  }

  void _continue() {
    final addrErr = _validateAddress(_addressController.text.trim());
    final amtErr = _validateAmount(_amountController.text.trim());
    setState(() {
      _addressError = addrErr;
      _amountError = amtErr;
    });
    if (addrErr != null || amtErr != null) return;

    final ngonka = _useGnk
        ? parseGnk(_amountController.text.trim())
        : BigInt.parse(_amountController.text.trim().replaceAll(',', ''));

    context.push('/send/confirm', extra: {
      'toAddress': _addressController.text.trim(),
      'amountNgonka': ngonka.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send'),
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
      body: ResponsiveCenter(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Recipient Address',
                errorText: _addressError,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(PlatformUtil.isDesktop
                      ? Icons.content_paste
                      : Icons.qr_code_scanner),
                  onPressed: _scanQr,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: PlatformUtil.isDesktop
                        ? null
                        : const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      errorText: _amountError,
                      border: const OutlineInputBorder(),
                      suffixText: _useGnk
                          ? GonkaConstants.displayDenom
                          : GonkaConstants.baseDenom,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _setMax,
                  child: const Text('MAX'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                ChoiceChip(
                  label: const Text('GNK'),
                  selected: _useGnk,
                  onSelected: (_) => _switchDenom(true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('ngonka'),
                  selected: !_useGnk,
                  onSelected: (_) => _switchDenom(false),
                ),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _continue,
                child: const Text('Continue'),
              ),
            ),
          ],
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
      appBar: AppBar(title: const Text('Scan QR Code')),
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
