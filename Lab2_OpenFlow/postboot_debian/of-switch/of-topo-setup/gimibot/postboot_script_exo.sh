#!/bin/bash
export PATH=/usr/local/bin/rubydir/bin:$PATH
host=$1
slice=`ruby -e "print '$2'[/[^+]*$/]"`
echo $host > /etc/hostname
/bin/hostname -F /etc/hostname
apt-get install psmisc
echo "---
:uid: $host-$slice
:uri: amqp://gimi3.casa.umass.edu
:environment: production
:debug: false" > /etc/omf_rc/config.yml
echo $PATH > /tmp/curpath.out
if grep 'Ubuntu' /etc/issue; then
restart omf_rc
else
/etc/init.d/omf_rc restart
fi
