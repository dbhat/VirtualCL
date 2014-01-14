#!/bin/bash

host=$1
slice=`ruby -e "print '$2'[/[^+]*$/]"`
echo $host > /etc/hostname
/bin/hostname -F /etc/hostname
echo "---
:uid: $host-$slice
:uri: xmpp://<%= \"$host-$slice-#{Process.pid}\" %>:<%= \"$host-$slice-#{Process.pid}\" %>@emmy9.casa.umass.edu
:environment: production
:debug: false" > /etc/omf_rc/config.yml
restart omf_rc
rvm install ruby-1.8.7-p374
rvm use 1.8.7
gem install gli

