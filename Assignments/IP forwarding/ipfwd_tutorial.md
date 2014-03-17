# Static Routing Assignment

In this assignment students will learn about the fundamentals of IP routing by 
setting up static routing in a 3-node topology.

## Preparation

In this [tutorial](http://groups.geni.net/geni/wiki/GENIEducation/SampleAssignments/IPRouting/Procedure) we describe a series of experiment 
that will allow a user to:
* Verify that a slice has been set up correct
* Establish static route using route command and enable IP forwarding
* Verify the correctness of static routing and IP forwarding 


## Verification of Topology 

After establishing the slice on which the experiment will be executed, the has to be verified for correctness. In this tutorial, we use an OMF experiment script that executes pings between neighbouring nodes.
This tutorial uses a [three-node topology] (https://raw.github.com/dbhat/VirtualCL/master/Assignments/IP%20forwarding/routetopology.png).
[![ScreenShot](https://raw.github.com/dbhat/VirtualCL/master/Assignments/IP%20forwarding/routetopology_video.png)](http://youtu.be/vt5fpE0bzSY)

The same experiment script can also be found in LabWiki. To run the experiment perform the following steps:

* Type "threenodes_step1.rb" in the search box of the "Prepare widget" in LabWiki. Select the the script from the list of scripts that pops up.
* Drag the "notepad" icon from "Prepare" widget to the 
"Execute" widget.
* Check if all the specified parameters are correct.
* Start the experiment.

## Set up Routing and IP forwarding in Experiment Topology

In this step static routing is set up using route command and IP forwarding is enabled.

The same experiment script can also be found in LabWiki. To run the experiment perform the following steps:

* Type "threenodes_step2.rb" in the search box of the "Prepare widget" in LabWiki. Select the the script from the list of scripts that pops up.
* Use the template and set up routing and enable IP forwarding.
* After making necessary changes in the template drag the "notepad" icon from "Prepare" widget to the 
"Execute" widget.
* Check if all the specified parameters are correct.
* Start the experiment.

The step2-routing.rb script can be easily adapted if the experimenter wishes to set up the routing between the nodes 
differently.

## Verification of Routing and IP forwarding

After establishing the routing, we use an OMF experiment script that executes ping between node A and node C via node B, to verify the correctness of IP forwarding.

The same experiment script can also be found in LabWiki. To run the experiment perform the following steps:

* Type "threenodes_step3.rb" in the search box of the "Prepare widget" in LabWiki. Select the the script from the list of scripts that pops up.
* Drag the "notepad" icon from "Prepare" widget to the 
"Execute" widget.
* Check if all the specified parameters are correct.
* Start the experiment.
