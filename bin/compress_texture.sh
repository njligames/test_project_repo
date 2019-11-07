texturetool=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool
filein=$1

fileoutbase=${filein%.*}
echo $fileoutbase

$texturetool -f PVR -e PVRTC --channel-weighting-perceptual --bits-per-pixel-2 -o ${fileoutbase}L4.pvrtc -p ${fileoutbase}L4.png $filein

