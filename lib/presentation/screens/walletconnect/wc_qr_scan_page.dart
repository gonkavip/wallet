import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../l10n/app_localizations.dart';

class WcQrScanPage extends StatefulWidget {
  const WcQrScanPage({super.key});

  @override
  State<WcQrScanPage> createState() => _WcQrScanPageState();
}

class _WcQrScanPageState extends State<WcQrScanPage> {
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
      appBar: AppBar(title: Text(AppLocalizations.of(context).wcConnectScan)),
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
