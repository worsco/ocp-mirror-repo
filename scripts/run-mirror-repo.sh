#!/bin/bash

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

dnf install -y createrepo_c dnf-utils

while :
do
echo "Start RPM repo mirroring"
dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhocp-${OPENSHIFT_VERSION}-for-rhel-8-x86_64-rpms
dnf reposync --releasever=${RHEL_VERSION} -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-baseos-eus-rpms
dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-baseos-rpms
dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-appstream-rpms
dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=rhel-8-for-x86_64-supplementary-rpms
dnf reposync --releasever=${RHEL_VERSION} -n -m --download-path=/var/www/html --repoid=codeready-builder-for-rhel-8-x86_64-rpms
echo "End RPM repo mirroring"

# Create the repo via createrepo_c
echo "Creating repos"
cd /var/www/html
createrepo_c ./

echo "Sleeping for 120 minutes"
sleep 3600
echo "One hour passed."
sleep 3600
echo ""

done

# How did you get here?!?  Return an error.
exit 1
