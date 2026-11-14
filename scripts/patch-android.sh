#!/bin/bash
set -e
RES=android/app/src/main/res
cp -r resources/android-res/* $RES/
find $RES -name 'splash.png' -exec cp resources/splash.png {} \;
M=android/app/src/main/AndroidManifest.xml
grep -q USE_BIOMETRIC $M || sed -i 's#<application#<uses-permission android:name="android.permission.USE_BIOMETRIC" />\n    <application#' $M
grep -q REQUEST_INSTALL_PACKAGES $M || sed -i 's#<application#<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />\n    <application#' $M
G=android/app/build.gradle
VER=$(tr -d '[:space:]' < VERSION)
VC=$(python3 -c "v=open('VERSION').read().strip().split('.')+['0','0'];print(int(v[0])*10000+int(v[1])*100+int(v[2]))")
sed -i -E "s/versionCode[[:space:]]+[0-9]+/versionCode $VC/; s/versionName[[:space:]]+\"[^\"]*\"/versionName \"$VER\"/" $G
grep -q "versionCode $VC" $G || { echo "!!! versionCode patch FAILED"; cat $G; exit 1; }
grep -q sirius.keystore $G || sed -i '0,/^android {/s#^android {#android {\n    signingConfigs {\n        debug {\n            storeFile file("../../sirius.keystore")\n            storePassword "sirius123"\n            keyAlias "sirius"\n            keyPassword "sirius123"\n        }\n    }#' $G
echo "patched: versionName $VER versionCode $VC"
grep -n "versionCode\|versionName" $G
