#!/bin/bash

if [ ! -d "artifacts" ]; then
  echo "No artifacts found."
  exit 2
fi

rm -rf appimages

mkdir -p appimages/artifacts

wget -nc https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x ./appimagetool-x86_64.AppImage

cd appimages
for file in ../artifacts/*; do
  if [[ -f "$file" && "$file" != *.so ]]; then
    appName=$(basename "$file")
    echo $appName
    # prepare AppDir
    mkdir -p $appName.AppDir/usr/{bin,lib}
    cp ../AppRun $appName.AppDir/AppRun
    sed -i "s/app/$appName/g" $appName.AppDir/AppRun
    chmod +x ./$appName.AppDir/AppRun
    printf '[Desktop Entry]\nName='$appName'\nExec='$appName'\nIcon='$appName'\nType=Application\nCategories=Utility;\n' > $appName.AppDir/$appName.desktop
    cp ../ton.png $appName.AppDir/$appName.png
    cp $file $appName.AppDir/usr/bin/
    cp ../build/openssl_3/libcrypto.so.3 \
      /lib/x86_64-linux-gnu/libatomic.so.1 \
      /lib/x86_64-linux-gnu/libsodium.so.23 \
      /lib/x86_64-linux-gnu/libz.so.1 \
      /lib/x86_64-linux-gnu/liblz4.so.1 \
      /lib/x86_64-linux-gnu/libmicrohttpd.so.12 \
      /lib/x86_64-linux-gnu/libreadline.so.8 \
      $appName.AppDir/usr/lib/

    chmod +x ./$appName.AppDir/usr/bin/$appName
    # create AppImage
    ./../appimagetool-x86_64.AppImage $appName.AppDir
    mv $appName-x86_64.AppImage artifacts/$appName
  fi
done

ls -larth artifacts
cp -r ../artifacts/{smartcont,lib} artifacts/
pwd
ls -larth artifacts
