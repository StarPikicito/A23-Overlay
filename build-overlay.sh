#!/bin/bash

# === Configuration ===
MODULE_NAME="VendorPowerOverlay"
BUILD_DIR="$(pwd)/$MODULE_NAME"
OUT_APK="$MODULE_NAME.apk"
SIGNED_APK="signed-$MODULE_NAME.apk"
KEYSTORE_PATH="$HOME/.android/debug.keystore"
ALIAS="androiddebugkey"
STOREPASS="android"
KEYPASS="android"

# === Tools ===
AAPT2=$(which aapt2)
APKSIGNER=$(which apksigner)
PLATFORM_JAR=$(find $ANDROID_HOME/platforms -name "android.jar" | sort | tail -n 1)

# === Check ===
if [[ -z "$AAPT2" || -z "$APKSIGNER" || -z "$PLATFORM_JAR" ]]; then
  echo "Missing required tools. Make sure aapt2, apksigner, and ANDROID_HOME are correctly set."
  exit 1
fi

# === Build ===
echo "Compiling resources..."
mkdir -p build
find $BUILD_DIR/res -name "*.xml" > build/files.txt

$AAPT2 compile --dir $BUILD_DIR/res -o build/res.zip
if [[ $? -ne 0 ]]; then
  echo "aapt2 compile failed"
  exit 1
fi

echo "Linking APK..."
$AAPT2 link -o $OUT_APK -I $PLATFORM_JAR --manifest $BUILD_DIR/AndroidManifest.xml -R build/res.zip --auto-add-overlay
if [[ $? -ne 0 ]]; then
  echo "aapt2 link failed"
  exit 1
fi

echo "Signing APK..."
$APKSIGNER sign --ks "$KEYSTORE_PATH" --ks-key-alias "$ALIAS" --ks-pass pass:$STOREPASS --key-pass pass:$KEYPASS --out "$SIGNED_APK" "$OUT_APK"
if [[ $? -eq 0 ]]; then
  echo "✅ Signed APK ready: $SIGNED_APK"
else
  echo "❌ Signing failed"
  exit 1
fi