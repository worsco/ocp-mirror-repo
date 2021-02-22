#!/bin/bash

function install_createrepo() {
  # Sometimes cdn.redhat.com is being blocked/cannot connect.
  # Let's try at least every 30 seconds for 10 attempts
  # and then continue

  myloop=1
  while [[ $"myloop" -le 10 ]] && [[ ! `which createrepo_c` ]];
  do
    dnf install -y createrepo_c
    if [[ ! `which createrepo_c` ]]; then
      echo "ERROR: Failed to install createrepo_c, sleeping for 30 seconds and retry"
      sleep 30
    fi
    myloop=$(($myloop+1))
  done
}

echo "RHEL_VERSION: $RHEL_VERSION"
# example: RHEL_VERSION: 8.2
echo "OPENSHIFT_VERSION: $OPENSHIFT_VERSION"
# example: OPENSHIFT_VERSION: 4.5

dnf config-manager --releasever=${RHEL_VERSION} \
--set-enabled rhocp-${OPENSHIFT_VERSION}-for-rhel-8-x86_64-rpms \
--set-enabled rhel-8-for-x86_64-baseos-rpms \
--set-enabled rhel-8-for-x86_64-appstream-rpms \
--set-enabled rhel-8-for-x86_64-supplementary-rpms \
--set-enabled codeready-builder-for-rhel-8-x86_64-rpms

install_createrepo

while :
do
echo "Start RPM repo mirroring"
#dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhocp-${OPENSHIFT_VERSION}-for-rhel-8-x86_64-rpms
dnf reposync --releasever=${RHEL_VERSION} -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-baseos-eus-rpms
dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-baseos-rpms
#dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-appstream-rpms
#dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-supplementary-rpms
#dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=codeready-builder-for-rhel-8-x86_64-rpms
echo "End RPM repo mirroring"

# Sometimes cdn.redhat.com is not accessible, try again
install_createrepo

# An aborted "createrepo_c" run leaves a ".repodata" directory.
# Delete the directory if it exists (assumption is we are the 
# only container running createrepo_c and no one else is).
if [[ -d /var/www/html/.repodata ]]; then
  rm -rf /var/www/html/.repodata
fi

# Create the repo via createrepo_c
echo "Creating repos"
cd /var/www/html
createrepo_c ./

# TODO Make this configurable with an env var
echo "Sleeping for 120 minutes"
sleep 3600
echo "One hour passed."
sleep 3600
echo ""

done

# How did you get here?!?  Return an error.
exit 1
