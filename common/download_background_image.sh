shopt -s expand_aliases
source ~/.bashrc

RANDOM_IMPL=$((RANDOM % 3))

if command -v yt-dlp >/dev/null 2>&1; then
  ytdownloader="yt-dlp"
# Otherwise, check if youtube-dl is installed
elif command -v youtube-dl >/dev/null 2>&1; then
  ytdownloader="youtube-dl"
else
  echo "Neither yt-dlp nor youtube-dl is installed."
  exit 1
  RANDOM_IMPL=$((RANDOM % 2))
fi

IMAGE_PATH=~/.local/share/backgrounds/live.jpg


case $RANDOM_IMPL in
  0)
    download() {
      lowprio ffmpeg -hide_banner -loglevel error  -y -i "https://stream.netco.de/LiveApp/streams/570476249623091947761256.m3u8" -frames:v 1 ${IMAGE_PATH}
    }
    ;;
  1)
    download() {
      lowprio wget -q https://onlineservices.glasgow.gov.uk/georgesquarewebcam/fullsize3.jpg -O /tmp/georgesquare.jpg && mv /tmp/georgesquare.jpg ${IMAGE_PATH}
    }
    ;;
  2)
    streamurl=""
    download() {
      lowprio ffmpeg -hide_banner -i ${streamurl} -y -f image2 -frames:v 1 ${IMAGE_PATH} || streamurl=$(${ytdownloader} -g "https://www.youtube.com/watch?v=kb4efymw-d0")
    }
    ;;
  3)
    streamurl=""
    download() {
      # we need the 4k screenshot and we need it over both screens
      lowprio ffmpeg -hide_banner -i ${streamurl} -y -f image2 -frames:v 1 ${IMAGE_PATH} || streamurl=$(${ytdownloader} -g "https://www.youtube.com/watch?v=oCEb3QFqxDk")
    }
    ;;
esac

while :
do
  download
  if ( LANG=en nmcli --terse --fields GENERAL.METERED dev show 2> /dev/null | grep -q yes ) ; then
    # metered connection
    # try to download and wait half an hour
    sleep 1800
  else
    # connection is unmetered
    if ( nmcli --fields type con show --active | grep -q ethernet ) ; then
      # active connection is ethernet
      load_average=$(cat /proc/loadavg | awk '{print $1}')
      sleep_time=$(echo "$load_average * 10" | bc)
      sleep_time=$(awk -v st="$sleep_time" 'BEGIN{print st<10?10:st}')
      sleep "$sleep_time"
    else
      # wait 5 minutes
      sleep 300
    fi
  fi
done
