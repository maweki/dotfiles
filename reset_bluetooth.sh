hciconfig hci0 down
rmmod btusb
modprobe btusb
hciconfig hci0 up
