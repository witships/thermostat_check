import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// QRコードの内容を返すためのデータ構造
class LocationData {
  final String storeName;
  final String thermometerId;

  LocationData(this.storeName, this.thermometerId);
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QRコードスキャン')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isProcessing) return; // 処理中の場合は重複実行を防ぐ

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? qrContent = barcodes.first.rawValue;

                if (qrContent != null) {
                  setState(() {
                    isProcessing = true; // 処理を開始
                  });

                  try {
                    // 例: "船橋店|2F東側1番" を解析
                    final parts = qrContent.split('|');
                    if (parts.length == 2) {
                      final data = LocationData(parts[0], parts[1]);
                      // 解析したデータを前の画面へ返す
                      Navigator.pop(context, data);
                    } else {
                      // 解析エラー
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    // その他のエラー
                    Navigator.pop(context);
                  }
                }
              }
            },
          ),
          const Positioned(
            bottom: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '温度計の近くのQRコードを画面に合わせてください',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
