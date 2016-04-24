#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

AIR_SDK="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"
echo $AIR_SDK

#Setup the directory.
echo "Making directories."

mkdir "$pathtome/platforms"
mkdir "$pathtome/platforms/mac"
mkdir "$pathtome/platforms/mac/release"
mkdir "$pathtome/platforms/mac/debug"

mkdir "$pathtome/platforms/win"
mkdir "$pathtome/platforms/win/release"

#Copy SWC into place.
echo "Copying SWC into place."
cp "$pathtome/../bin/BitTorrentANE.swc" "$pathtome/"

#Extract contents of SWC.
echo "Extracting files form SWC."
unzip "$pathtome/BitTorrentANE.swc" "library.swf" -d "$pathtome"

#Copy library.swf to folders.
echo "Copying library.swf into place."
cp "$pathtome/library.swf" "$pathtome/platforms/mac/release"
cp "$pathtome/library.swf" "$pathtome/platforms/mac/debug"
cp "$pathtome/library.swf" "$pathtome/platforms/win/release"

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/mac/BitTorrentANE/Build/Products/Release/BitTorrentANE.framework" "$pathtome/platforms/mac/release"
cp -R -L "$pathtome/../../native_library/mac/BitTorrentANE/Build/Products/Debug/BitTorrentANE.framework" "$pathtome/platforms/mac/debug"
cp -R -L "$pathtome/../../native_library/win/BitTorrentANE/Release/BitTorrentANE.dll" "$pathtome/platforms/win/release"

#Run the build command.
echo "Building Release."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/BitTorrentANE.ane" "$pathtome/extension_multi.xml" \
-swc "$pathtome/BitTorrentANE.swc" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/release" "BitTorrentANE.framework" "library.swf" \
-platform Windows-x86 -C "$pathtome/platforms/win/release" "BitTorrentANE.dll" "library.swf"

echo "Building Debug. MAC only"
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/BitTorrentANE-debug.ane" "$pathtome/extension_osx.xml" \
-swc "$pathtome/BitTorrentANE.swc" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/debug" "BitTorrentANE.framework" "library.swf"

if [[ -d "$pathtome/debug" ]]
then
rm -r "$pathtome/debug"
fi


mkdir "$pathtome/debug"
unzip "$pathtome/BitTorrentANE-debug.ane" -d  "$pathtome/debug/BitTorrentANE.ane/"

rm -r "$pathtome/platforms"
rm "$pathtome/BitTorrentANE.swc"
rm "$pathtome/library.swf"
rm "$pathtome/BitTorrentANE-debug.ane"