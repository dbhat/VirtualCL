
Secsh channel 1 opened.
Welcome to Ubuntu 12.04.4 LTS (GNU/Linux 3.2.0-60-virtual x86_64)
 * Documentation:  https://help.ubuntu.com/
  System information as of Wed Aug 27 16:04:40 UTC 2014
  System load:  0.0               Users logged in:     0
  Usage of /:   6.3% of 25.59GB   IP address for eth0: 10.103.0.23
  Memory usage: 4%                IP address for eth1: 192.168.3.2
  Swap usage:   0%                IP address for eth2: 192.168.5.1
  Processes:    79
  => There is 1 zombie process.
  Graph this data and manage this system at:
    https://landscape.canonical.com/
70 packages can be updated.
43 updates are security updates.
Get cloud support with Ubuntu Advantage Cloud Guest
  http://www.ubuntu.com/business/services/cloud
The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.
Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
#!/bin/sh
cd /tmp
hn=`cat /etc/hostname| cut -d'.' -f 1`
##### Check if file is there #####
#if [ ! -f "./installed.txt" ]
#then
       #### Create the file ####
 #       sudo touch "./installed.txt"
       #### Run  one-time commands ####
       #Install necessary packages
       # Install custom software
#fi
##### Run Boot-time commands
#echo $hn
if [ $hn=="left" ] || [ $hn=="right" ]
then
    sudo ovs-vsctl set-fail-mode br-switch standalone
fi
