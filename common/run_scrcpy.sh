which scrcpy &> /dev/null || exit 0
while true
do
  sleep 30
  lsusb -d 18d1:4ee2 && scrcpy -Sw
done
