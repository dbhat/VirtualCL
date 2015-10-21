# Data Center Assignment

This course module gives an intuition behind how the client requests are shared among the servers in a data-center

*  Students will be given a template of the controller where certain functionalities like the algorithm used for routing, have to be implemented
*  Overall, students will learn any-casting, how the packet destination is modified for routing, different algorithms for load balancing
*  Assignments will be run through LabWiki and students can visualize the working through graphs and debug using the logs.

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


## Working

A 5-node topology [figure](http://groups.geni.net/geni/raw-attachment/wiki/GEC20Agenda/LabWiki/ModuleA/GEC20_simple_topo.png) is used for this purpose. The number of nodes can be scaled up. In this assignment,two nodes are servers, two nodes are clients and one node is the switch . Both the servers are anycasted to have the same alias ip address. The clients make continuous http requests to the servers. The existence of multiple servers from the clients are abstracted using any-casting. Based on the algorithm, the requests will be routed to different servers from the OpenFlow switch. Algorithm can be round robin, based on throughput or random.  In this module, round robin algorithm is used. Alternate requests will be sent to the same server in this algorithm. Also, requests from the client will be sent to the same server if the flow is active between that server and client. Once the flow expires after a particular time interval, requests will be sent according to the algorithm. A dictionary is used to make sure that arp packets and the data are not sent to different servers by the algorithm.

## Set up the data-center

* The first step is to add the openflow switch and configure the bridge with interfaces. To do so, SSH into the “switch” node and execute the following commands:
>ovs-vsctl add-br test

 This command creates an ovs bridge named test. Any name can be given for the bridge.
 
>ovs-vsctl add-port test eth1

>ovs-vsctl add-port test eth2

>ovs-vsctl add-port test eth3

>ovs-vsctl add-port test eth4

 These commands configure the bridge with the interfaces. eth1-eth4 specifies the interfaces on node “switch”
 
 >ovs-vsctl set-controller test tcp:IP.OF.CONTROLLER:6653
 
 In this case, the IP.OF.CONTROLLER would be 127.0.0.1
>ovs-ofctl show test 	

* Download the scripts from emmy9.casa.umass.edu/datacenter.rb and emmy9.casa.umass.edu/fdb.rb. The script "datacenter.rb" is used to implement the data-center functionality. The controller makes use of a simple database implementation. 	The name of the script is “fdb.rb”. This is where the node-mapping information is populated on flooding to all the nodes. The controller assumes that eth1 and eth2 are servers and others are clients.

 * The next step is installing Apache server on Servers(eth1 and eth2) using the commands:
>sudo apt-get install apache2

 * For stopping and restarting, use the following commands:
>sudo /etc/init.d/apache2 restart

>sudo /etc/init.d/apache2 stop

 * The next step is anycasting. It is done so that all the servers have the same alias ip address "192.168.1.15". In this way, the number of servers are abstracted from the clients. 
 Run the following commands on all the servers:
>sudo ifconfig lo:1 192.168.1.15 netmask 255.255.255.255 up

 To verify if it is anycasted, run the following command:
>ifconfig lo:1

 * The next step is to modify the /etc/hosts on all the clients so that they know the new alias ip of the servers. To do this, run the following command:
>sudo vim /etc/hosts

* Add the following entry in the file:
>192.168.1.15    example.com

 By doing this, a domain name is assigned to the alais ip for the servers. Download the sample file from emmy9.casa.umass.edu/FCC_3-26-2013.pptx on the server nodes at the location /var/www. Later, download requests for this file will be sent from the clients through oedl scripts.

## Verification of data-center functionality

 * You can start the controller with the following command: 
>trema run datacenter.rb
 * After you have started the controller switch over to LabWiki. Download the script "datacenter.oedl" from www.. Make appropriate changes according to the server and client mappings and run the experiments on labwiki. From the graph, you can see if there was data transfer between all servers and clients. 



