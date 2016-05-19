#!/bin/sh

#  rundebug.sh
#  
#
#  Created by Mini on 17/05/2015.
#

#Get the path to the script and trim to get the directory.
echo "Setting path to current firectory to:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

# set the path to the installed SDK to a handy variable for the script
AIR_SDK="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"
echo $AIR_SDK

echo "Running"

echo $pathtome/bin-debug/BitTorrentANESample-app.xml

"$AIR_SDK"/bin/adl -profile extendedDesktop \
-extdir $pathtome/../native_extension/ane/debug/ \
-nodebug \
$pathtome/bin-debug/BitTorrentANESample-app.xml