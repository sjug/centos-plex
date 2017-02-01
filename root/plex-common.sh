#!/bin/bash

function getVersionInfo {
  local version="$1"
  local token="$2"
  declare -n remoteVersion=$3
  declare -n remoteFile=$4
  
  local versionInfo
  
  if [ "${version,,}" = "plexpass" ]; then
    versionInfo="$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=8&distro=centos&X-Plex-Token=${token}")"
  elif [ "${version,,}" = "public" ]; then
    versionInfo="$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=centos")"
  else
    versionInfo="$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=8&distro=centos&X-Plex-Token=${token}&version=${version}")"
  fi
  
  # Get update info from the XML.  Note: This could countain multiple updates when user specifies an exact version with the lowest first, so we'll use first always.
  remoteVersion=$(echo "${versionInfo}" | sed -n 's/.*Release.*version="\([^"]*\)".*/\1/p')
  remoteFile=$(echo "${versionInfo}" | sed -n 's/.*file="\([^"]*\)".*/\1/p')
}


function installFromUrl {
  installFromRawUrl "https://plex.tv/${1}"
}

function installFromRawUrl {
  local remoteFile="$1"
  curl -J -L -o /tmp/plexmediaserver.rpm "${remoteFile}"
  local last=$?

  # test if deb file size is ok, or if download failed
  if [[ "$last" -gt "0" ]] || [[ $(stat -c %s /tmp/plexmediaserver.rpm) -lt 10000 ]]; then
    echo "Failed to fetch update"
    exit 1
  fi

  yum --nogpgcheck localinstall -y /tmp/plexmediaserver.rpm
  rm -f /tmp/plexmediaserver.rpm
}
