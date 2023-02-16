which scrcpy &> /dev/null || exit 0
while true
do
  sleep 10
  lsusb -d 18d1:4ee2 && ( bluetoothctl connect E8:78:29:C2:5B:14 & scrcpy -Sw & wait && bluetoothctl disconnect E8:78:29:C2:5B:14 )
done
