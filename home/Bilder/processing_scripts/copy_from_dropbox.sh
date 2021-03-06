#!/bin/sh

if [ $# -eq 0 ] 
	then folder=$(dirname $0)
fi

if [ $# -eq 1 ]
	then folder=$1
fi
echo "Importing new images from:"
echo $folder
TFILE="/tmp/$(basename $0).$$.tmp"
find "$folder" -iname "*.jpg" -print | grep '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' > $TFILE
find "$folder" -iname "*.png" -print | grep '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' >> $TFILE
find "$folder" -iname "*.3gp" -print | grep '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' >> $TFILE
find "$folder" -iname "*.mp4" -print | grep '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' >> $TFILE
while read image
do
	FILENAME=$(basename "$image")
	tfolder="$(echo $FILENAME | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' )"
	mkdir -p /home/maweki/Bilder/$tfolder
	#echo $image to /home/maweki/Bilder/$tfolder
	cp -p -v -u "$image" /home/maweki/Bilder/$tfolder
done < $TFILE
rm $TFILE
