#Dockerfile to build Pentaho's Business Analytics frontend 
# v 2.1.12
# Created using pentaho 'archive' instructions from https://help.pentaho.com/Documentation/5.4/0F0/0P0/020/0B0
# and info from https://github.com/rxacevedo/docker-pentaho-ba/blob/master/Dockerfile
#
# Docker Build Instructions:
#  docker build -t pentaho-ba .
# Docker Run Instructions:
#
#  #For testing the build process on a pc.
#   docker run -d --name pentaho-ba -p 8080:8080 -e Tier=Test -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-ba/opt/pentaho:/opt/pentaho wusa/pentaho-ee-ba:ba_6.0 &
#
#  #On first ever run, you must include the PGPWD (postgres adimn) password to initialize the database after that it's optional.
#   docker run -i --name pentaho-ba-test -p 10800:8080 -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db-test -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db-test:pentaho-db-test -v /docker/mounts/pentaho-ba-test/opt/pentaho:/opt/pentaho wusa/pentaho-ee-ba:ba_6.0 &
#
#  #On subsequent boots, (after db is initialized), run non-interactive.
#   #dev
#    docker run -d --name pentaho-ba-dev -p 10808:8080 -e Tier=Dev -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db-dev -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db-dev:pentaho-db-dev -v /docker/mounts/pentaho-ba-dev/opt/pentaho:/opt/pentaho --memory 6344M --memory-swap -1 --oom-kill-disable --cpu-shares=512 --cpuset-cpus="0-1" wusa/pentaho-ee-ba:ba_6.0 &
#   #test
#    docker run -d --name pentaho-ba-test -p 10800:8080 -e Tier=Test -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db-test -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db-test:pentaho-db-test -v /docker/mounts/pentaho-ba-test/opt/pentaho:/opt/pentaho --memory 6344M --memory-swap -1 --oom-kill-disable --cpu-shares=512 --cpuset-cpus="0-1" wusa/pentaho-ee-ba:ba_6.0 &
#   #Prod
#    docker run -d --name pentaho-ba-prod -p 10804:8080 -e Tier=Prod -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db-prod -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db-prod:pentaho-db-prod -v /docker/mounts/pentaho-ba-prod/opt/pentaho:/opt/pentaho --memory 6656M --memory-swap -1 --oom-kill-disable --cpu-shares=1024 --cpuset-cpus="0-5" wusa/pentaho-ee-ba:ba_6.0 &
#
FROM phusion/baseimage:0.9.18
MAINTAINER Dave Barnum <Dave_Barnum@wycliffe.org>

#Update Ubuntu and add repo for postgres 9.4
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
	curl -s http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -; \
	apt-get update; \
	apt-get upgrade -y

##################################
#  Install Major Dependences     #
##################################
RUN apt-get install -y ca-certificates curl wget zip unzip vim postgresql-client-9.4 expect rsync; \
	#pentaho requires xvfb when X server is unavailable.; \
	apt-get install -y xvfb; \
	#Tomcat's APM library helps with tomcat speed. Need version 1.1.30+ (not available from normal repo.); \
	sudo add-apt-repository ppa:pharmgkb/trusty -y; \
	sudo apt-get update; \
	sudo apt-get install libtcnative-1 -y
ENV LD_LIBRARY_PATH "/usr/lib/x86_64-linux-gnu/"

#Scripts used for startup & initialization.
COPY scripts /scripts
RUN chmod 777 /scripts; \
	chmod 755 /scripts/*.sh; \
	chmod 755 /scripts/*.exp;

#** Install Java ***
#*******************

RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections; \
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections; \
	add-apt-repository ppa:webupd8team/java -y; \
	apt-get update; \
	apt-get install oracle-java8-installer -y -qq;

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
#** Done Installing Java **

##################################
# Setup Pentaho Environment      #
##################################
#Set the target version.  This will be used by the run script to determine if we need to upgrade the version on disk.
ENV PENTAHO_BA_TARGET_VER="6.0.1.2"

ENV PENTAHO_JAVA_HOME=$JAVA_HOME
ENV PENTAHO_HOME=/opt/pentaho
ENV DI_HOME=/opt/pentaho/server/biserver-ee/pentaho-solutions/system/kettle
ENV CATALINA_HOME=$PENTAHO_HOME/server/biserver-ee/tomcat
ENV PENTAHO_INSTALLED_LICENSE_PATH=$PENTAHO_HOME/.pentaho/.installedLicenses.xml
ENV CATALINA_OPTS="-Djava.awt.headless=true -Xms4g -Xmx6g -XX:MaxMetaspaceSize=256m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000 -DDI_HOME=$DI_HOME -Dpentaho.installed.licenses.file=$PENTAHO_INSTALLED_LICENSE_PATH"

#Set Passwords for pentaho database users - default is 'password'
ENV jcr_user_pwd="ppaiChangeMem887"
ENV hibuser_pwd="s5gChangeMe877"
ENV pentaho_user_pwd="0apChangeMe5S66"

#Set download locations for pentaho packages
ENV pkg_biserver_ee="https://file.location.to/biserver-ee-6.0.1.0-386-dist.zip"
ENV pkg_paz_plugin="https://file.location.to/paz-plugin-ee-6.0.1.0-386-dist.zip"
ENV pkg_pdd_plugin="https://file.location.to/pdd-plugin-ee-6.0.1.0-386-dist.zip"
ENV pkg_pir_plugin="https://file.location.to/pir-plugin-ee-6.0.1.0-386-dist.zip"
ENV pkg_mobile_plugin="https://file.location.to/pentaho-mobile-plugin-6.0.1.0-386-dist.zip"
ENV pkg_operations_mart="https://file.location.to/pentaho-operations-mart-6.0.1.0-386-dist.zip"

#Set download locations for pentaho service packs
ENV pkg_SP201601_60="https://file.location.to/SP201601-6.0.zip"
ENV pkg_SP201602_60="https://file.location.to/SP201602-6.0.zip"



#Create Pentaho user & Create main folder structure
RUN groupadd -g 7654 pentaho; \
	useradd -s /bin/bash -d ${PENTAHO_HOME} -u 7654 -g 7654 pentaho; \
	mkdir -p ${PENTAHO_HOME}; \
	mkdir -p /tmp/pentaho/build; \
	chown -R pentaho:pentaho /opt/pentaho

#Default build folder.  Contains xml file for unpacking the pentaho downloads. Also contains JDBC drivers.
COPY build /tmp/pentaho/build
RUN chown -R pentaho:pentaho /tmp/pentaho

#We don't actually install Pentaho in this dockerfile.  This is because Pentaho is not like other programs you install and update via apt-get.
#It is installed via placing packages in the right folder.  Since those packages might already exist in a running environment we only need to install
#dependencies here.  The rest, including installation of a new environment and upgrades can be handled by the service_start_pentaho.sh script.
#Additionally, new installation has been disabled in our environment because we don't need that anymore. (to prevent building a new environment when something unexpected happens like if NFS is not present.)
ENV ALLOW_NEW_INSTALL="YES"

#Setup auto start process for Pentaho BA
RUN mkdir -p /etc/service/ba; \
	ln -s /scripts/service_start_pentaho.sh /etc/service/ba/run;
	
#Setup auto start process for Pentaho BA Hypersonic (sample data database - aka steel wheels)
ENV SERVICE_ENABLE_HYPERSONIC=Y
RUN mkdir -p /etc/service/hypersonic; \
	ln -s /scripts/service_start_hypersonic.sh /etc/service/hypersonic/run;

#Set the timezone.
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Cleanup
RUN apt-get clean; \
	rm -rf /var/lib/apt/lists/* /var/tmp/*

#We use baseimage-docker's my_init process.
CMD ["/sbin/my_init"]
