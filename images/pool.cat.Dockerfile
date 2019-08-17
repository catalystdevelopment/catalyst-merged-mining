FROM pool:latest
MAINTAINER n8tb1t <n8tb1t@gmail.com>

COPY catalyst.config.json ./config.json

CMD if [ "$MODULE" = "ALL" ] ; then node init.js; else node init.js -module=$MODULE; fi
