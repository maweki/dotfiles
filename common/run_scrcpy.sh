which scrcpy &> /dev/null || exit 0
while true
do
  sleep 10
  lsusb -d 18d1:4ee2 && scrcpy -Sw
done
