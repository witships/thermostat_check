import 'dart:io'; // File操作のため

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http; // ★ この行を追加

import 'camera_screen.dart';
import 'qr_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OcrApp());
}

class OcrApp extends StatelessWidget {
  const OcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '温度記録DXアプリ',
      theme: ThemeData(
        primarySwatch: Colors.green, // 送信ボタンの色に合わせる
      ),
      home: const RecordScreen(), // メイン画面
    );
  }
}

// 記録画面 (状態を持つため StatefulWidget を使用)
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  // --- 状態変数（State）の定義 ---
  // QRコードから取得した場所情報
  String? storeName;
  String? thermometerId;

  // OCRで読み取った温度
  String? recognizedTemperature;

  // カメラのインスタンスを保持する変数 (一度だけ初期化するため)
  late CameraDescription _camera;
  bool _isCameraInitialized = false;

  // 温度の手動入力/修正用コントローラー
  final TextEditingController _tempController = TextEditingController();

  // --- 初期化・破棄処理 ---

  @override
  void initState() {
    super.initState();
    // main()で WidgetsFlutterBinding.ensureInitialized() を呼んだ後、
    // ここでカメラの初期化を開始します。
    _initializeCamera(); // 変更なし
  }

  @override
  void dispose() {
    _tempController.dispose();
    super.dispose();
  }

  // カメラを初期化する非同期関数
  Future<void> _initializeCamera() async {
    try {
      // デバイスで利用可能なカメラのリストを取得
      final cameras = await availableCameras();
      // 最初の背面カメラを選択
      _camera = cameras.first;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      // カメラが見つからないなどのエラー処理
      print('Camera initialization error: $e');
      // UIでエラーを通知するなどの処理
    }
  }

  // --- UIの構築 ---
  @override
  Widget build(BuildContext context) {
    // 必須情報が揃っているか確認
    final bool canSubmit =
        storeName != null &&
        thermometerId != null &&
        _tempController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('現場温度記録')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. QRコード読み取りセクション (次のステップで実装)
            _buildQrScanSection(),
            const SizedBox(height: 24),

            // 2. 場所情報の表示セクション
            _buildLocationInfo(),
            const SizedBox(height: 24),

            // 3. 温度計撮影/OCRセクション (次のステップで実装)
            _buildOcrSection(),
            const SizedBox(height: 24),

            // 4. 送信ボタン
            _buildSubmitButton(canSubmit),
          ],
        ),
      ),
    );
  }

  // --- 各UI部品の実装 (ここに処理を記述していく) ---

  // QRコード読み取りUI（仮）
  Widget _buildQrScanSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.qr_code_scanner, size: 40),
        title: const Text('1. QRコードを読み取る'),
        trailing: ElevatedButton(
          onPressed: _startQrScan, // 次のステップで実装
          child: const Text('スキャン'),
        ),
      ),
    );
  }

  // 場所情報の表示UI
  Widget _buildLocationInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '【記録場所情報】',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('店舗名', storeName ?? '---'),
            _buildInfoRow('温度計名', thermometerId ?? '---'),
          ],
        ),
      ),
    );
  }

  // 温度計撮影/OCR UI（仮）
  Widget _buildOcrSection() {
    // カメラ初期化状態を取得 (以前のステップで修正済み)
    final bool isReady = _isCameraInitialized;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. 温度を読み取る',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  // カメラが初期化されていなければ null (非活性化)
                  onPressed: isReady ? _startCameraCapture : null,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(isReady ? '撮影/再撮影' : 'カメラ準備中'),
                ),
              ],
            ),
            const Divider(height: 20),

            // OCR結果の表示と編集可能な入力フィールド
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempController,
                    // 数字と小数点のみを入力可能にする
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '温度 (OCR結果を修正可)',
                      hintText: '例: 19.5',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '°C',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // デバッグ情報: OCRが数字を検出できなかった場合のメッセージ
            if (recognizedTemperature != null && recognizedTemperature!.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'OCRが数字を検出できませんでした。手動で入力してください。',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 送信ボタンUI
  Widget _buildSubmitButton(bool isActive) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: isActive ? Colors.green : Colors.grey, // 活性化状態
      ),
      onPressed: isActive ? _submitData : null, // 活性化されていれば送信
      child: Text(
        '送信',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black54,
          fontSize: 18,
        ),
      ),
    );
  }

  // その他ヘルパーウィジェット
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- アプリの処理 (次のステップで実装) ---

  void _startQrScan() async {
    // QrScannerScreenを起動し、結果を待つ
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    // result が LocationData のインスタンスである場合
    if (result != null && result is LocationData) {
      setState(() {
        storeName = result.storeName;
        thermometerId = result.thermometerId;
        // 温度計のOCR結果など、他の状態をリセットする場合
        recognizedTemperature = null;
        _tempController.clear();
      });
    }
  }

  // カメラ起動とOCRロジックをここに実装
  void _startCameraCapture() async {
    if (!_isCameraInitialized) {
      // カメラの初期化が完了していない場合は処理を中断
      print("Camera not initialized.");
      return;
    }

    // 1. カメラ撮影画面に遷移
    final resultImagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        // 新しいカメラ撮影ウィジェットを起動 (次のセクションで作成)
        builder: (context) => CameraScreen(camera: _camera),
      ),
    );

    if (resultImagePath != null) {
      // 2. OCRを実行
      final recognizedText = await _recognizeText(resultImagePath);

      // 3. 数字を抽出・整形
      final extractedNumber = _extractNumber(recognizedText);

      // 4. 状態を更新
      setState(() {
        recognizedTemperature = extractedNumber;
        _tempController.text = extractedNumber; // Inputフィールドにセット
      });
    }
  }

  // 撮影した画像からテキストを認識する関数
  Future<String> _recognizeText(String path) async {
    final inputImage = InputImage.fromFile(File(path));

    // スクリプト指定なしで、デフォルトのテキスト認識エンジンを使用
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    // ★ デバッグログを追加 (コンソールに出力されます)
    print('--- OCR Raw Result ---');
    print(recognizedText.text); // 認識された生のテキスト
    print('----------------------');

    return recognizedText.text;
  }

  // 抽出されたテキストから数字のみを抽出する関数
  String _extractNumber(String text) {
    // 正規表現を使用して、小数点を含む数字列を抽出
    final regExp = RegExp(r"(\d+(\.\d+)?)");
    final match = regExp.firstMatch(text);
    return match?.group(0) ?? '';
  }

  // Googleフォームへのデータ送信ロジックをここに実装
  void _submitData() async {
    // 1. Googleフォームで取得した情報をここに設定
    const String formUrl =
        'https://docs.google.com/forms/d/e/1FAIpQLSdA_AR364v_-XI_4grkAB-4it-m-tU_tXb4qQqbvyMffer_XA/formResponse'; // ★ このURL全体を設定
    const String entryStoreName = 'entry.500118680'; // 質問1のフィールド名
    const String entryThermometerId = 'entry.1630966067'; // 質問2のフィールド名
    const String entryTemperature = 'entry.789567294'; // 質問3のフィールド名

    // 2. フォームに送信するデータを作成
    // 必ずnullチェックを行い、デフォルト値（空文字列など）を設定する
    final data = {
      entryStoreName: storeName ?? '',
      entryThermometerId: thermometerId ?? '',
      entryTemperature: _tempController.text, // 入力フィールドの現在の値
    };

    try {
      // 3. HTTP POSTリクエストの実行
      final response = await http.post(
        Uri.parse(formUrl),
        headers: {
          // フォーム送信に必要なヘッダー
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: data, // データ本体
      );

      // 4. 結果の判定とUI通知
      if (response.statusCode == 302 || response.statusCode == 200) {
        // ★ 200も成功に追加
        // データ送信自体は成功
        _showSuccessDialog();
      } else {
        _showErrorDialog('送信エラー', 'ステータスコード: ${response.statusCode}');
        print('HTTP Error: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('ネットワークエラー', e.toString());
      print('Network Error: $e');
    }
  }

  // 送信成功時に表示するダイアログ
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ 成功'),
        content: const Text('温度記録をGoogleフォームに送信しました。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 送信後、フィールドをリセットする
              _resetFields();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // エラー時に表示するダイアログ
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('❌ $title'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // フィールドをリセットするヘルパー関数
  void _resetFields() {
    setState(() {
      storeName = null;
      thermometerId = null;
      recognizedTemperature = null;
      _tempController.clear();
    });
  }
}
