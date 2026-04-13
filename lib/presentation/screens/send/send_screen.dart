import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../config/amount_input_formatter.dart';
import '../../../config/constants.dart';
import '../../../core/crypto/address_service.dart';
import '../../../core/platform_util.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/balance_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

enum _AddressErr { empty, invalid, self }
enum _AmountErr { empty, notPositive, insufficient, invalid }

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _useGnk = true;
  _AddressErr? _addressErr;
  _AmountErr? _amountErr;

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
          final ngonka = BigInt.parse(input.replaceAll(',', ''));
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

  _AddressErr? _validateAddress(String address) {
    if (address.isEmpty) return _AddressErr.empty;
    if (!AddressService.validate(address)) return _AddressErr.invalid;
    final wallet = ref.read(activeWalletProvider);
    if (wallet != null && address == wallet.address) {
      return _AddressErr.self;
    }
    return null;
  }

  _AmountErr? _validateAmount(String input) {
    if (input.isEmpty) return _AmountErr.empty;
    try {
      final ngonka = _useGnk
          ? parseGnk(input)
          : BigInt.parse(input.replaceAll(',', ''));
      if (ngonka <= BigInt.zero) return _AmountErr.notPositive;
      final balanceAsync = ref.read(balanceProvider);
      return balanceAsync.whenOrNull(data: (balance) {
        if (ngonka > balance.spendable) return _AmountErr.insufficient;
        return null;
      });
    } catch (_) {
      return _AmountErr.invalid;
    }
  }

  String? _addressErrorText(AppLocalizations l10n) {
    final e = _addressErr;
    if (e == null) return null;
    return switch (e) {
      _AddressErr.empty => l10n.sendErrorEnterAddress,
      _AddressErr.invalid => l10n.sendErrorInvalidAddress,
      _AddressErr.self => l10n.sendErrorSelfSend,
    };
  }

  String? _amountErrorText(AppLocalizations l10n) {
    final e = _amountErr;
    if (e == null) return null;
    return switch (e) {
      _AmountErr.empty => l10n.sendErrorEnterAmount,
      _AmountErr.notPositive => l10n.sendErrorAmountPositive,
      _AmountErr.insufficient => l10n.sendErrorInsufficient,
      _AmountErr.invalid => l10n.sendErrorInvalidAmount,
    };
  }

  void _continue() {
    final addrErr = _validateAddress(_addressController.text.trim());
    final amtErr = _validateAmount(_amountController.text.trim());
    setState(() {
      _addressErr = addrErr;
      _amountErr = amtErr;
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendTitle),
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
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.sendRecipientLabel,
                errorText: _addressErrorText(l10n),
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
                    inputFormatters: [commaToDotInsertedFormatter],
                    decoration: InputDecoration(
                      labelText: l10n.sendAmountLabel,
                      errorText: _amountErrorText(l10n),
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
                  child: Text(l10n.sendMaxButton),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.sendUnitGnk),
                  selected: _useGnk,
                  onSelected: (_) => _switchDenom(true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.sendUnitNgonka),
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
                child: Text(l10n.sendContinue),
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
          title: Text(AppLocalizations.of(context).sendScanQr)),
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
