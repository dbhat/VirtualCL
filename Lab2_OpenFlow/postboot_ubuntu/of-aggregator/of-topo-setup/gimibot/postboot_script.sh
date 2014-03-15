#!/bin/bash

read -r slice1 </var/emulab/boot/nickname
slicename=$(echo $slice1 | cut -f2 -d.)

host1=$(hostname)

host=$(echo $host1 | cut -f1 -d.)

slice=`ruby -e "print '$slicename'[/[^+]*$/]"`
echo $host > /etc/hostname
/bin/hostname -F /etc/hostname
echo 'amqp://emmy9.casa.umass.edu' > /var/omf/communication_url
echo $host-$slice > /var/omf/node_uri
restart omf_rc
