# Load-Balancer Assignment

In this assignment you will learn how to implement the load-balancer using OpenFlow switches. You will explore how to implement your own Openflow controller in this experiment.

Overall we will do the following:

*  Implement the Openflow controller
*  Verify the correctness of the Openflow controller

## Preparation for Routing Assignment

To learn about OpenFlow, check out this link: [http://groups.geni.net/geni/wiki/OpenFlow](http://groups.geni.net/geni/wiki/OpenFlow).

To learn about the trema controller, check out this link:[http://trema.github.io/trema/](http://trema.github.io/trema/).
 
Also you should understand the topology you will be utilizing for this tutorial. It can be found [here] (http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/DesignSetup/OpenFlowLBExo.png).

Helpful tips about debugging your OpenFlow controller can be found in [http://groups.geni.net/geni/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/Appendices#E.Tips:DebugginganOpenFlowController] (http://groups.geni.net/geni/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/Appendices#E.Tips:DebugginganOpenFlowController).

## Preparation for utilizing Geni Environment

Make sure that before starting you have setup the correct topology and have the proper setup of SSH keys. The following videos will walk you through these steps.

- Part 1: [Understanding the Geni Portal](http://www.youtube.com/watch?v=H61s9sRP8Qk)
+ Part 2: [Setting up your SSH Keys](http://www.youtube.com/watch?v=3gssCqOvR-Q)
+ Part 3: [Reserving Resources](http://server.casa.umass.edu/~zink/ECE374/recordings/assign1_topo_setip.mp4)

In the case of this assignment the only thing that is different is the name of the RSpec you have to choose. So instead of using “ECE3743Node” (as shown around 1:50 minutes into the video) you now have to use RSpec titled “load-balancer” 

## Experiment

You will implement a load-balancing OpenFlow controller capable of collecting flow status data from OpenFlow switches and using it to divide traffic between dissimilar network paths so as to achieve full bandwidth utilization. We are going to use OpenFlow Virtual Switches (OVS) and implement a Load Balancer OpenFlow Controller using Trema. 

The topology is shown in the [figure](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/OpenFlowLBExo.png), The topology consists of six nodes: inside and outside are regular nodes, left and right are regular switches, aggregator and switch are OpenFlow switches

*Inside and Outside Nodes: These nodes can be any ExoGENI Virtual Nodes.
*Switch: This node is a Linux host running Open vSwitch. Your Load Balancing OpenFlow Controller will be running on this node as well. This is the main node that you will be working on.
*Traffic Shaping Nodes (Left and Right): These are Linux hosts with two network interfaces. You can configure netem on the two traffic shaping nodes to have differing characteristics; the specific values don’t matter, as long as they are reasonable. Use several different delay/loss combinations as you test your load balancer.
*Aggregator: This node is a Linux host running Open vSwitch with a switch controller that will cause TCP connections to “follow” the decisions made by your OpenFlow controller on the Switch node. You will not need to change anything on this node, you only need to implement the OpenFlow controller on node "Switch".

## Implementation of OpenFlow controller

We have already installed a template for OpenFlow controller. The name of the template is load-balancer.rb. It is located in /root/load-balancer.rb. You need to implement few methods in this template to get the required functionality. 
You can design the controller in your own way. You can choose your own algorithm:

* 1) The load balancer can pick path randomly: each path has 50% of the chance to get picked.
* 2) It can pick path in a round robin fashion: right path is picked first, then left path, etc.
* 3) It can pick path based on the total number of bytes sent out to each path: the one with fewer bytes sent out is picked.
* 4) It can pick path based on the total number of flows sent out to each path: the one with fewer flows sent out is picked.
* 5) It can pick path based on the total throughput sent out to each path: the one with more throughput is picked.

Once you choose the algorithm for load-balancing, do the following:

* 1) SSH into the switch node and run the following commands, 
*		sudo bash
*		source  /etc/profile.d/rvm.sh
* 2)We have already installed and configured the OVS switch, if you want to take a look at the configuration and understand more look at the output of these commands:
*       ovs-vsctl list-br
*       ovs-vsctl list-ports br0
*       ovs-vsctl show
*       ovs-ofctl show br0		
* 3) You need to calculate the average per-flow throughput observed from both left and right paths. The modifications need to happen in the function "stats_reply" in load-balancer.rb. It is the function that will be called when the OpenFlow Controller receives a flow_stats_reply message from the OpenFlow Switch. Here in our case, we update the flow statistics so that "decide_path()" can make the right decision.
* 4) In function "decide_path", change the path decision based on the calculated average per-flow throughput. It is the function that makes path decisions. It returns the path choices based on flow statistics.

## Verification of correctness of the OpenFlow controller

* 1) Run your controller using the command:
*		trema run /root/load-balancer.rb
* 2) After the controller starts, you should be able to see the following message:
*		OpenFlow Load Balancer Conltroller Started!
		Switch is Ready! Switch id: 196242264273477
* 3) When the controller is ready, login to Labwiki. A script called loadbalancer.oedl is already preloaded for you. You can retrieve it from the Prepare column. You should change the name of the slice to yours in the script.
* 4) When you run this script, graph will be plotted. These graphs can be used to verify the correctness of the controller.
* 5) You can also check the controller's log on the switch node to see if the controller is working as expected. 
* 6) Once the experiment is finished, stop the controller using the command Clrl + C.

