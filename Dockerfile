FROM java:8
MAINTAINER Claus Stadler <cstadler@informatik.uni-leipzig.de>

ENV VERSION 2.1.1
ENV BASEDIR /opt/archiva/
ENV INSTALLDIR $VERSION

ENV ARCHIVEDIR apache-archiva-$VERSION
ENV ARCHIVENAME apache-archiva-$VERSION-bin.tar.gz
ENV ARCHIVEURL http://archive.apache.org/dist/archiva/$VERSION/binaries/$ARCHIVENAME

# Upgrade the base image
RUN \
  apt-get update && \
  apt-get upgrade -y

# Add an archiva user
RUN \
  mkdir -p "$BASEDIR" && \
  useradd -d "$BASEDIR" -m archiva && \
  chown -R archiva:archiva $BASEDIR

USER archiva

# Change to the base directory
#WORKDIR "$BASEDIR"
WORKDIR /opt/archiva/

# Download and extract archiva

RUN \
  wget "$ARCHIVEURL" && \
  tar -zxvf "$ARCHIVENAME" && \
  rm "$ARCHIVENAME" && \
  mv "$ARCHIVEDIR" "$INSTALLDIR"

#WORKDIR "$BASEDIR/$INSTALLDIR"
WORKDIR 2.1.1

# Backup the folders that we want to get from the volume
RUN \
  mkdir bak && \
  mv conf bak && \
  mv logs bak && \
  mv temp bak

VOLUME ["/opt/archiva/2.1.1/archiva-data"]

# Create symbolic links to the data volume
RUN \
  for x in 'temp' 'conf' 'logs' 'data' 'repositories'; do ln -s "archiva-data/$x" "$x"; done
  

#VOLUME ["$BASEDIR/$INSTALLDIR/archiva-data"]

# Standard web ports exposted
EXPOSE 8080/tcp 8443/tcp

WORKDIR bin

#ENTRYPOINT ["$BASEDIR/$INSTALLDIR/bin/archiva console"]
ENTRYPOINT ["./archiva", "console"]


