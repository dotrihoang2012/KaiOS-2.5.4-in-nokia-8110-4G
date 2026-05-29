#!/bin/bash

# Create a Nokia 8110 4G stock recovery compatible update.zip archive
# Requirements: JRE 6+, zip
# Usage: sign.sh [input_directory] [output.zip]

SCRIPTDIR="$(dirname "$(realpath "$0")")"
KEYDIR="$(realpath ${SCRIPTDIR}/../Keys)"
TEMPDIR="$SCRIPTDIR/tmp"

mkdir -p "$TEMPDIR"
cp -r "$1"/* "$TEMPDIR"/
mkdir -p "$TEMPDIR/META-INF/com/google/android/" 
cp "$SCRIPTDIR/update-binary" "$TEMPDIR/META-INF/com/google/android/" 
pushd $TEMPDIR
zip -9 -r update.zip .
popd
java -Xmx2048m -cp "$SCRIPTDIR/signapk.jar:$SCRIPTDIR/conscrypt-openjdk-uber.jar:$SCRIPTDIR/bcprov-jdk15on-1.64.jar:$SCRIPTDIR/bcpkix-jdk15on-1.64.jar" SignApk -w "$KEYDIR/testkey.x509.pem" "$KEYDIR/testkey.pk8" "$TEMPDIR/update.zip" $2
rm -rf $TEMPDIR

echo "Signed archive created at $2"
