# VLC Assignment

In this assignment you will learn how dynamic adaptive streaming over http works.

Overall we will do the following:

*  Install VLC Client and Apache Server
*  Instrumentize and measure the DASH bit-rate using LabWiki.

## Preparation for Routing Assignment

To learn about OpenFlow, check out this link: [http://groups.geni.net/geni/wiki/OpenFlow](http://groups.geni.net/geni/wiki/OpenFlow).

To learn about the trema controller, check out this link:[http://trema.github.io/trema/](http://trema.github.io/trema/).
 
Also you should understand the topology you will be utilizing for this tutorial. It can be found [here] (http://groups.geni.net/geni/attachment/wiki/GENIEducation/SampleAssignments/VLCDashTutorial/DesignSetup/vlcdash.png).

## Preparation for utilizing Geni Environment

Make sure that before starting you have setup the correct topology and have the proper setup of SSH keys. The following videos will walk you through these steps.

- Part 1: [Understanding the Geni Portal](http://www.youtube.com/watch?v=H61s9sRP8Qk)
+ Part 2: [Setting up your SSH Keys](http://www.youtube.com/watch?v=3gssCqOvR-Q)
+ Part 3: [Reserving Resources](http://server.casa.umass.edu/~zink/ECE374/recordings/assign1_topo_setip.mp4)

In the case of this assignment the only thing that is different is the name of the RSpec you have to choose. So instead of using “ECE3743Node” (as shown around 1:50 minutes into the video) you now have to use RSpec titled “VLC” 

## Experiment

Using OML instrumented VLC, we can visualize the VLC decision bitrate, which is the actual played bitrate; the VLC empirical rate, which is the instantly measured throughput, for deciding the next segment's decision bit rate.

VLC also provides other interesting statistics, such as the buffer size (percentage), each chunk's downloading time, etc. These can also be easily measured and displayed using GIMI tools by modifying the defGraph function towards your interested parameter.

The topology is shown in the [figure](http://groups.geni.net/geni/attachment/wiki/GENIEducation/SampleAssignments/VLCDashTutorial/DesignSetup/vlcdash.png), The topology consists of six nodes: inside and outside are regular nodes, left and right are regular switches, aggregator and switch are OpenFlow switches.

* Inside and Outside Nodes: These nodes can be any ExoGENI Virtual Nodes.
* Switch: This node is a Linux host running Open vSwitch. Your Load Balancing OpenFlow Controller will be running on this node as well. This is the main node that you will be working on.
* Traffic Shaping Nodes (Left and Right): These are Linux hosts with two network interfaces. You can configure netem on the two traffic shaping nodes to have differing characteristics; the specific values don’t matter, as long as they are reasonable. Use several different delay/loss combinations as you test your load balancer.
* Aggregator: This node is a Linux host running Open vSwitch with a switch controller that will cause TCP connections to “follow” the decisions made by your OpenFlow controller on the Switch node. You will not need to change anything on this node, you only need to implement the OpenFlow controller on node "Switch".

## Installation of Apache Server

You need to login to the "Outside" node and execute the following commands. The first 4 lines of this script install and set-up the Apache server. The rest of the script downloads a sample DASH video from emmy9.casa.umass.edu and hosts it on the server that you just set up.

*	#!/bin/bash

*	apt-get update
*	apt-get -y install apache2
*	apt-get -y install apache2-threaded-dev
*	vim /etc/apache2/apache2.conf (Add the content: "ServerName localhost" to the end of this file. Then, save and quit)

*	apache2ctl restart
*	mkdir /root/DASH_BuckBunny
*	curl http://emmy9.casa.umass.edu/wget_download.sh -o /root/wget_download.sh
*	chmod +x /root/wget_download.sh
*	sh /root/wget_download.sh

## Installation of VLC Client

The actual VLC Client which requests the video can be set up using this script. For streaming this video from the Apache server and in order to instrumentize and measure the DASH bit-rate using LabWiki we need to execute the following commands.
This script needs to be executed manually to monitor the progress of VLC Client installation.

*	#!/bin/bash
*	apt-get install -y --force-yes subversion
*	apt-get -y --force-yes update
*	apt-get build-dep -y --force-yes vlc
*	cd /root/
*	svn co http://witestlab.poly.edu/repos/omlapps/vlc/vlc-2.1.0-git/
*	cd /root/vlc-2.1.0-git
*	apt-get install -y --force-yes liboml2-dev checkinstall build-essential cmake libtool automake autoconf git-core ffmpeg libxcb-shm0-dev libxcb-xv0-dev libx11-xcb-dev libcdparanoia-dev libcdio-paranoia-dev libcdio-cdda-dev libqt4-dev qt4-dev-tools qt4-qmake nasm yasm libasm-dev lua5.1
*	apt-get autoremove
*	./configure LIBS="-loml2" --enable-run-as-root
*	make
*	make install
*	mv /usr/local/bin/vlc /usr/local/bin/vlc_app
*	mv /usr/local/bin/vlc /usr/local/bin/vlc_app
*	vi /usr/local/bin/vlc
*	(Paste the content:
*		#!/bin/sh
*		export LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"
*		export TERM=xterm
*		vlc_app "$@") save and quit
	
*chmod +x /usr/local/bin/vlc


## Execution of LabWiki Script

* 1) SSH into the switch node and run the following commands, 
*		sudo bash
*		source  /etc/profile.d/rvm.sh
* 2)We have already installed and configured the OVS switch, if you want to take a look at the configuration and understand more look at the output of these commands:
*       ovs-vsctl list-br
*       ovs-vsctl list-ports br0
*       ovs-vsctl show
*       ovs-ofctl show br0		
* 3) Run your controller using the command:
*		trema run /root/load-balancer.rb
* 4) After the controller starts, you should be able to see the following message:
*		OpenFlow Load Balancer Conltroller Started!
		Switch is Ready! Switch id: 196242264273477
* 3) When the controller is ready, login to Labwiki. A script called VLC.oedl is already preloaded for you. You can retrieve it from the Prepare column. You should change the name of the slice to yours in the script.
* 4) When you run this script, graph will be plotted. These graphs can be used to visualise Decision rate, Empirical rate, VLC DASH Buffer Percentage.

