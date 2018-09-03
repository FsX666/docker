#!/bin/bash
read -p 'Hostname: ' Hostname
read -p 'Sonde: ' Sonde

SONDE=$Sonde
HOSTNAME=$Hostname

DROP=$(docker exec -it xymon ./usr/lib/xymon/client/bin/xymon 127.0.0.1 "drop $HOSTNAME $SONDE")
echo "Done"
