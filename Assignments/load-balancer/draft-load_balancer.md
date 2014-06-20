# Load-Balancer Assignment

In this assignment you will learn how to implement the load-balancer using OpenFlow switches. You will explore how to implement your own Openflow controller in this experiment.

Overall we will do the following:

*  Implement the Openflow controller
*  Verify the correctness of the Openflow controller

## Preparation for Routing Assignment

To learn about learning-switch, check out this link: [https://www.opennetworking.org/images/stories/downloads/sdn-resources/white-papers/wp-sdn-newnorm.pdf](https://www.opennetworking.org/images/stories/downloads/sdn-resources/white-papers/wp-sdn-newnorm.pdf).

To learn about the trema controller, check out this link:[http://trema.github.io/trema/](http://trema.github.io/trema/).
 
Also you should understand the topology you will be utilizing for this tutorial. It can be found [here] (http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/DesignSetup/OpenFlowLBExo.png).

## Preparation for utilizing Geni Environment

Make sure that before starting you have setup the correct topology and have the proper setup of SSH keys. The following videos will walk you through these steps.

- Part 1: [Understanding the Geni Portal](http://www.youtube.com/watch?v=H61s9sRP8Qk)
+ Part 2: [Setting up your SSH Keys](http://www.youtube.com/watch?v=3gssCqOvR-Q)
+ Part 3: [Reserving Resources](http://server.casa.umass.edu/~zink/ECE374/recordings/assign1_topo_setip.mp4)

In the case of this assignment the only thing that is different is the name of the RSpec you have to choose. So instead of using “ECE3743Node” (as shown around 1:50 minutes into the video) you now have to use RSpec titled “l” 

## Experiment

You will implement a load-balancing OpenFlow controller capable of collecting flow status data from OpenFlow switches and using it to divide traffic between dissimilar network paths so as to achieve full bandwidth utilization. We are going to use OpenFlow Virtual Switches (OVS) and implement a Load Balancer OpenFlow Controller using Trema. 

The topology is shown in the [figure](http://groups.geni.net/geni/attachment/wiki/GEC17Agenda/AdvancedOpenFlow/Procedure/OpenFlowLBExo.png), The topology consists of six nodes: inside and outside are regular nodes, left and right are regular switches, aggregator and switch are OpenFlow switches

*Inside and Outside Nodes: These nodes can be any ExoGENI Virtual Nodes.
*Switch: This node is a Linux host running Open vSwitch. Your Load Balancing OpenFlow Controller will be running on this node as well. This is the main node that you will be working on.
*Traffic Shaping Nodes (Left and Right): These are Linux hosts with two network interfaces. You can configure netem on the two traffic shaping nodes to have differing characteristics; the specific values don’t matter, as long as they are reasonable. Use several different delay/loss combinations as you test your load balancer.
*Aggregator: This node is a Linux host running Open vSwitch with a switch controller that will cause TCP connections to “follow” the decisions made by your OpenFlow controller on the Switch node. You will not need to change anything on this node, you only need to implement the OpenFlow controller on node "Switch".





