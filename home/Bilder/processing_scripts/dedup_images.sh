for d in ~/Bilder/????-??-??/
do
  fdupes --delete --noprompt $d
done
duperemove -rdAh ~/Bilder/
