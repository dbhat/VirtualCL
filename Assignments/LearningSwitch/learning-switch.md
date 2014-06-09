# Learning switch Assignment

In this assignmment you will learn about to implement the learning switch capability that is used by Ethernet switches by using a software-based OpenFlow switch. The functionality of the learning switch will both be explored with the LabWiki script.

Overall we will do the following:

*  Set-up the learning switch
*  Verify the correctness of the learning-switch

## Preparation for Routing Assignment

To learn about learning-switch, check out this link: [https://www.opennetworking.org/images/stories/downloads/sdn-resources/white-papers/wp-sdn-newnorm.pdf](https://www.opennetworking.org/images/stories/downloads/sdn-resources/white-papers/wp-sdn-newnorm.pdf).

To learn about the trema controller, check out this link:[http://trema.github.io/trema/](http://trema.github.io/trema/).
 
Also you should understand the topology you will be utilizing for this tutorial. It can be found [here] (http://emmy9.casa.umass.edu/Eswer/learning-switch/topology.png).

## Preparation for utilizing Geni Environment

Make sure that before starting you have setup the correct topology and have the proper setup of SSH keys. The following videos will walk you through these steps.

- Part 1: [Understanding the Geni Portal](http://www.youtube.com/watch?v=H61s9sRP8Qk)
+ Part 2: [Setting up your SSH Keys](http://www.youtube.com/watch?v=3gssCqOvR-Q)
+ Part 3: [Reserving Resources](http://server.casa.umass.edu/~zink/ECE374/recordings/assign1_topo_setip.mp4)

In the case of this assignment the only thing that is different is the name of the RSpec you have to choose. So instead of using “ECE3743Node” (as shown around 1:50 minutes into the video) you now have to use RSpec titled “learning-switch” 

## Experiment

The goal of this assignment is to implement the learning switch capability that is used by Ethernet switches by using a software-based OpenFlow switch. In the case of the topology shown in the [figure](http://emmy9.casa.umass.edu/Eswer/learning-switch/topology.png), this software switch is to be implemented in node “switch”. All the other nodes represent regular hosts. To realize this implementation of a learning switch it is your task to implement and trema-based OpenFlow controller. You will have to verify the correct functionality of the learning switch by creating an experiment script in which any node A pings nodes B – node E in LabWiki.

## Working

In the topology shown in the [figure](http://emmy9.casa.umass.edu/Eswer/learning-switch/topology.png), the switch node will act as the learning switch, which connect nodes A-E with each other. Whenever a regular node pings any regular node for the first time, the switch does not know the destination address of the node. At this point, the switch node floods the packet to all the nodes it is connected to. When it receives a reply to the flood, this information will be used to populate its switching table. Hereafter,whenever any node wants to ping any other nodes, the switch node will fetch the information from the table. For this purpose, two scripts are already preloaded in the switch node, namely learning-switch.rb and fdb.rb. The second script offers rudimentary database functionality that is used to maintain the switching table.

## Set up the learning switch

* 1)	The first step is to add the openflow switch and configure the bridge with interfaces. To do so, SSH into the “switch” node and execute the following commands:
*	a)	sudo bash
*		source /etc/profile.d/rvm.sh
*		ifconfig
*		Check if all the five interfaces from eth1-eth5 are up in the switch node.
*	b)	ovs-vsctl add-br test
*		This command creates an ovs bridge named test. Any name can be given for the bridge.
*	c)	ovs-vsctl add-port test eth1
*		ovs-vsctl add-port test eth2
*		ovs-vsctl add-port test eth3
*		ovs-vsctl add-port test eth4
*		ovs-vsctl add-port test eth5
*		These commands configure the bridge with the interfaces. eth1-eth5 specifies the interfaces on node “switch”
*	d)	ovs-vsctl set-controller test tcp:IP.OF.CONTROLLER:6653
*		In this case, the IP.OF.CONTROLLER would be 127.0.0.1
*	e)	ovs-ofctl show test 
*		dpid is “data path id” that uniquely identifies an OpenFlow instance on the device. This command gives the 16 digit dpid. Make note of the [dpid](http://emmy9.casa.umass.edu/Eswer/learning-switch/dpid.png).
*	f)	We have already installed a template for the OpenFlow controller in /users/ekishore. The name of the template is “learning-switch-template.rb”. Open this file using any text editor and replace the copied dpid into this [file](http://emmy9.casa.umass.edu/Eswer/learning-switch/template.png).	
* 2)	This script is used to implement the learning switch functionality. To achieve that you have to add additional functionality to the “def packet_in datapath_id, message” routine. That is the only routine that you need to work on. The others are all set. This routine implements the functionality required when a packet enters the switch. 
* 3)	The controller makes use of a simple database implementation, which is installed in the same directory as the controller. The name of the script is “fdb.rb”. This is where the information is populated on flooding to all the nodes.


## Verification of learning-switch functionality

* 1)	You can start the controller with the following command: 
*		trema run learning-switch-template.rb
* 2)	After you have started the controller switch over to LabWiki. To prove the functionality of your learning switch controller use the “step1_threenode.rb” experiment script. This script does automatic pinging between nodes.
* 3)	Modify that script such that any node A pings all other hosts (nodes B – E)




