#!/bin/sh

lsusb -d 18d1:4ee2 &> /dev/null || exit 0

# Retrieve the detailed list of files from the phone's Camera directory in one go.
files_info=$(adb shell ls -l /storage/self/primary/DCIM/Camera/)

echo "$files_info" | while read -r line
do
    # Skip lines that do not contain file details
    if [ "${line:0:1}" != "-" ]; then
        continue
    fi
    
    # Extract file name from the line
    f=$(echo "$line" | awk '{print $NF}')
    
	format=${f:0:3}
	ext=${f##*.}
	
	# Extract the modification time from the line (7th column is the time)
    atime=$(echo "$line" | awk '{print $7}')
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
		mkdir -p "${targetdir}"
		adb pull -a "storage/self/primary/DCIM/Camera/${f}" "${target}" &> /dev/null
	fi
done
