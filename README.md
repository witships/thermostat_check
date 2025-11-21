# サーモスタット温度記録アプリ (Thermostat Check)

現場の温度計の数値を記録・報告するためのFlutterアプリケーションです。

## 主な機能

* **QRコードによる場所の特定**:
    * 温度計の近くに設置されたQRコードをスキャンし、「店舗名」と「温度計ID」を自動で入力します。
* **カメラによる温度のOCR読み取り**:
    * スマートフォンのカメラで温度計の数値を撮影し、OCR（光学文字認識）技術を使って温度の数値を自動で読み取ります。
* **手動修正**:
    * OCRで読み取った数値が間違っていた場合に、手動で修正する機能も備えています。
* **データ送信**:
    * 読み取った場所情報と温度を記録し、送信します。（現在は送信処理はプレースホルダーです）

## DB

https://docs.google.com/spreadsheets/d/1TP6VTF4Kq5WNmG_6NY31H3BML0CckmqQwmFzF9FlAbQ/edit?resourcekey=&gid=2141786318#gid=2141786318

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
