@echo off
echo ========================================
echo MinQ - 実機テスト用ビルド
echo ========================================

echo.
echo [1/5] 依存関係の確認...
flutter pub get
if %errorlevel% neq 0 (
    echo エラー: 依存関係の取得に失敗しました
    pause
    exit /b 1
)

echo.
echo [2/5] コード生成...
flutter packages pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo 警告: コード生成でエラーが発生しましたが、続行します
)

echo.
echo [3/5] 静的解析...
flutter analyze
if %errorlevel% neq 0 (
    echo 警告: 静的解析でエラーが発見されましたが、続行します
)

echo.
echo [4/5] テストの実行...
flutter test
if %errorlevel% neq 0 (
    echo 警告: テストでエラーが発生しましたが、続行します
)

echo.
echo [5/5] デバッグビルドの作成...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo エラー: ビルドに失敗しました
    pause
    exit /b 1
)

echo.
echo ========================================
echo ビルド完了！
echo APKファイル: build\app\outputs\flutter-apk\app-debug.apk
echo ========================================
echo.
echo 実機テストの手順:
echo 1. USBデバッグを有効にした Android デバイスを接続
echo 2. flutter devices でデバイスを確認
echo 3. flutter run でアプリを起動
echo.
pause