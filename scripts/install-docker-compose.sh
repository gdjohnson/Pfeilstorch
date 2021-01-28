#!/bin/bash

# This installs Docker and Docker-Compose on a totally new & blank Ubuntu 18.04 server,
# based on: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/

function log_message {
  echo "`date --iso-8601=seconds --utc` install-docker: $1"
}

echo
log_message "Installing Docker and Docker-Compose..."


# ------- Add Docker repository

# Install packages to allow apt to use a repository over HTTPS:
apt-get update
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Check that the fingerprint is correct:
# (see https://docs.docker.com/engine/installation/linux/ubuntu/#install-using-the-repository)
MATCHING_KEY_ROW="`apt-key fingerprint 0EBFCD88 | grep '9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88'`"
if [ -z "$MATCHING_KEY_ROW" ]; then
	echo
	log_message "ERROR: Bad Docker GPG key fingerprint. [TyEDKRFNGR]"
	log_message "Don't continue installing."
	log_message "Instead, ask for help in the Docker forums: https://forums.docker.com/,"
	log_message "and show them the output from running this:"
	log_message "    apt-key fingerprint 0EBFCD88"
	log_message "and include a link to this script too, here it is:"
	log_message "    https://github.com/debiki/talkyard-prod-one/blob/master/scripts/install-docker-compose.sh"
	echo
	exit 1
fi

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


# ------- Install Docker CE:

# List versions: apt-cache madison docker-ce
# Upgrade:
#   service docker stop
#   apt-get update
#   apt-get upgrade  # hmm seems to upgrade Docker too, also if installed via docker-ce=...
#   apt-get -y install docker-ce=VERSION   # or is this needed?

apt-get update
apt-get -y install docker-ce=5:19.03.5~3-0~ubuntu-bionic

log_message "Testing Docker: running 'docker run hello-world' ..."

HELLO_WORLD="$(docker run hello-world | grep -i 'hello ')"
if [ -z "$HELLO_WORLD" ]; then
	echo
	log_message "Error installing or starting Docker: 'docker run hello-world' doesn't work. [EdEDKRBROKEN]"
	log_message "Ask for help in the Talkyard forum: https://www.talkyard.io/forum/"
	log_message "and/or in the Docker forums: https://forums.docker.com/"
	echo
	exit 1
fi

log_message "Docker worked fine. Installing Docker-Compose ..."


service docker start

# Make everything start automatically on server startup:
systemctl enable docker

# Install Docker Compose (see https://github.com/docker/compose/releases)

curl -L https://github.com/docker/compose/releases/download/1.25.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

log_message
log_message
log_message "*** Done ***"
log_message
log_message "Docker and Docker-Compose installed."
log_message
log_message "This should print 'docker-compose version 1.25.0 ...' or later:"
log_message "----------------------------"
docker-compose -v
log_message "----------------------------"
echo

