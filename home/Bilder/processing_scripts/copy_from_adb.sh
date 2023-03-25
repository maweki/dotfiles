#!/bin/sh

lsusb -d 18d1:4ee2 &> /dev/null || exit 0

for f in `adb shell ls /storage/self/primary/DCIM/Camera/`
do
	format=${f:0:3}
	ext=${f##*.}
	atime=`adb shell ls -ll storage/self/primary/DCIM/Camera/${f} | awk '{ print $7 }'`
	year=${f:4:4}
	month=${f:8:2}
	day=${f:10:2}
	h=${atime:0:2}
	m=${atime:3:2}
	s=${atime:6:2}
	basename=${f%%.*}
	rest=${basename:19}
	rest_=`echo ${rest} | sed "s/_/-/"`
	targetname="${year}-${month}-${day} ${h}.${m}.${s}${rest_}.${ext}"
	targetdir=~/Bilder/${year}-${month}-${day}/
	target=${targetdir}${targetname}
	if [ ! -f "${target}" ]
	then
		adb pull -a "storage/self/primary/DCIM/Camera/${f}" "${target}" &> /dev/null
	fi
done
