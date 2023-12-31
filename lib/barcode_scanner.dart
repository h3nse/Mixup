import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mixup_app/scanner_error_widget.dart';

class BarcodeScannerWithoutController extends StatefulWidget {
  const BarcodeScannerWithoutController({super.key});

  @override
  State<BarcodeScannerWithoutController> createState() =>
      _BarcodeScannerWithoutControllerState();
}

class _BarcodeScannerWithoutControllerState
    extends State<BarcodeScannerWithoutController>
    with SingleTickerProviderStateMixin {
  String scanResult = '';

  void _updateResult(BarcodeCapture capture) {
    setState(() {
      scanResult = capture.barcodes.first.rawValue ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scanResult),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                fit: BoxFit.contain,
                errorBuilder: (context, error, child) {
                  return ScannerErrorWidget(error: error);
                },
                onDetect: (capture) {
                  _updateResult(capture);
                  // String result = capture.barcodes.first.rawValue ?? '';
                  // Future.microtask(() => Navigator.pop(context, result));
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, scanResult);
        },
        child: const Icon(Icons.barcode_reader),
      ),
    );
  }
}
