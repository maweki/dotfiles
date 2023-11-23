shopt -s expand_aliases
source ~/.bashrc

download () {
  lowprio ffmpeg -hide_banner -loglevel error  -y -i "https://stream.netco.de/LiveApp/streams/570476249623091947761256.m3u8" -frames:v 1 ~/.local/share/backgrounds/live.jpg
}



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




