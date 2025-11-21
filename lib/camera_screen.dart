import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // カメラコントローラーを初期化
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high, // 解像度はOCRのためにMediumまたはHighが推奨
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 撮影処理
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      // 画像を撮影し、一時ファイルに保存
      final XFile file = await _controller.takePicture();

      // 画像のパスを前の画面に返して、OCRに渡す
      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      print(e);
      // 撮影失敗時は元の画面に戻る
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('温度計を撮影')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // カメラプレビュー
            return CameraPreview(_controller);
          } else {
            // カメラ初期化中はローディングを表示
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // 撮影ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
