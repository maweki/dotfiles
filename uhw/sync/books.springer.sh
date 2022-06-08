wget -q -O /tmp/books.springer "https://link.springer.com/search/csv?facet-discipline=%22Computer+Science%22&facet-content-type=%22Book%22&showAll=false&sortOrder=newestFirst"
comm -13 <(sort ~/sync/literature/books.springer) <(sort /tmp/books.springer) >> ~/sync/literature/books.springer.new
cat /tmp/books.springer > ~/sync/literature/books.springer
