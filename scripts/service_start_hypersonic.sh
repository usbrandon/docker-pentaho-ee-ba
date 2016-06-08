#!/bin/bash
# The hypersonic database is only used for Sample data (steel wheels).  In a production environment it should not be needed.
#################################
## Start Pentaho Hypersonic DB ##
#################################
#Only run the hypersonic database in test tier.
#If you don't want to run this in prod, adjust the if statement below.
if [[ $SERVICE_ENABLE_HYPERSONIC == "Y" || $SERVICE_ENABLE_HYPERSONIC == "y" ]]; then
  while [ ! $(ps aux|grep "[c]atalina"|awk '{print $2}') ]; do
    #If the service has not been started yet sleep for 4 minutes.
    sleep 240
  done
  sleep 60
  echo "Starting Hypersonic DB"
  exec setuser pentaho $PENTAHO_HOME/server/biserver-ee/data/start_hypersonic.sh
fi

#Baseimage-Docker will try to launch this process repeatedly if it is allowed to exit.  Instead sleep
sleep 9999
exit