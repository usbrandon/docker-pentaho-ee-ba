#!/bin/bash
#Before we start pentaho we must check the environment.  This could be a brand new container/volume or it could be a new container mounting a volume with an existing version.  We also need to check if the existing version needs to be updated.

#######################################
## Check Pentaho Business Analyitics ##
#######################################
#First we must check if Business Analytics is installed & if it is at the appropriate service pack.
if [ ! -f "$PENTAHO_HOME/automation/pentaho_bi_installed_version.txt" ]; then 
  echo "BA Version file does not exist."
  if [ -d "$PENTAHO_HOME/server/biserver-ee/start-pentaho.sh" ]; then
    echo "The BA version file does not exist, but the $PENTAHO_HOME/server folder does.  This was unexpected."
	sleep 5
	exit
  else
    #Only install pentaho if we are allowed to..
	if [[ $ALLOW_NEW_INSTALL == "YES" ]]; then
      echo "Installing Pentaho BA."
	  #Pentaho BA is not installed.  Run the script to install Pentaho BA from a clean slate.
	  #Run as pentaho user.
	  mkdir -p ${PENTAHO_HOME}/automation
	  chown -R pentaho:pentaho $PENTAHO_HOME
	  /sbin/setuser pentaho /scripts/install_pentaho_ba_6_0_1_0.sh
	  /sbin/setuser pentaho /scripts/upgrade_pentaho_ba.sh
	else
	  echo "Not installing BA because ALLOW_NEW_INSTALL is set to $ALLOW_NEW_INSTALL"
	fi
  fi
else
  #Pentaho is installed.  Check which version is installed.
  PENTAHO_BA_INSTALLED_VER=$(grep -oP 'biserver-ee-\K[\d\.\-]*' $PENTAHO_HOME/automation/pentaho_bi_installed_version.txt)
  if [[ $PENTAHO_BA_INSTALLED_VER == $PENTAHO_BA_TARGET_VER ]]; then
    #Pentaho is at the target version.  Do nothing here.
	echo "Pentaho is at the target version."
  else
    echo "Pentaho BA version is at $PENTAHO_BA_INSTALLED_VER which is different than the target version of $PENTAHO_BA_TARGET_VER.  Starting upgrade script."
	/sbin/setuser pentaho /scripts/upgrade_pentaho_ba.sh
  fi
fi
#Components are installed.

#Copy any new JDBC Drivers that have been added
cp -f /tmp/pentaho/build/jdbc/* $PENTAHO_HOME/server/biserver-ee/tomcat/lib/
chown -R pentaho:pentaho $PENTAHO_HOME/server/biserver-ee/tomcat/lib/

#Clean up /tmp
rm -rf /tmp/pentaho/*
#############################
## Start Pentaho BA Server ##
#############################
#Clean the runtime environment
/scripts/clean_pentaho_run_env.sh
#Start the pentaho process
exec setuser pentaho $PENTAHO_HOME/server/biserver-ee/tomcat/bin/catalina.sh run

