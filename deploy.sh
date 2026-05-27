#!/usr/bin/env bash
set -e

JAVA=/home/amaanq/projects/grapheneos/prebuilts/jdk/jdk21/linux-x86/bin/java
APKSIGNER=/home/amaanq/projects/grapheneos/out_adevtool_deps/host/linux-x86/framework/apksigner.jar
KEYSTORE=~/.android/debug.keystore
SRC=/home/amaanq/projects/graphene/Vanadium/src
SIGNED=/tmp/signed_apks

mkdir -p "$SIGNED"

echo "==> Signing APKs..."
$JAVA -jar $APKSIGNER sign \
	--ks $KEYSTORE --ks-key-alias androiddebugkey \
	--ks-pass pass:android --key-pass pass:android \
	--out $SIGNED/TrichromeLibrary.apk \
	$SRC/out/vanadium/apks/TrichromeLibrary64.apk

$JAVA -jar $APKSIGNER sign \
	--ks $KEYSTORE --ks-key-alias androiddebugkey \
	--ks-pass pass:android --key-pass pass:android \
	--out $SIGNED/TrichromeChrome.apk \
	$SRC/out/vanadium/apks/TrichromeChrome64.apk

$JAVA -jar $APKSIGNER sign \
	--ks $KEYSTORE --ks-key-alias androiddebugkey \
	--ks-pass pass:android --key-pass pass:android \
	--out $SIGNED/TrichromeWebView.apk \
	$SRC/out/vanadium/apks/TrichromeWebView64.apk

echo "==> Deploying to device"
adb -s 2A291JEHN03207 root
adb -s 2A291JEHN03207 remount

adb -s 2A291JEHN03207 push $SIGNED/TrichromeLibrary.apk /product/app/TrichromeLibrary/TrichromeLibrary.apk
adb -s 2A291JEHN03207 push $SIGNED/TrichromeChrome.apk /product/app/TrichromeChrome/TrichromeChrome.apk
adb -s 2A291JEHN03207 push $SIGNED/TrichromeWebView.apk /product/app/TrichromeWebView/TrichromeWebView.apk

echo "==> Clearing package cache"
adb -s 2A291JEHN03207 shell "rm /data/system/packages.xml /data/system/packages.xml.reservecopy"

echo "==> Soft rebooting device"
adb -s 2A291JEHN03207 reboot userspace

echo "Done"
