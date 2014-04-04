# Static Routing Assignment

In this assignmment you will learn about the fundamentals of IP routing by 
setting up static routing in a 3-node topology. The Ping and Route applications will both be explored with LabWiki experiment scripts.

Overall we will do the following with three parts:

*  Verify that a slice has been set up correct
*  Establish static routes using the route command and enable IP forwarding
*  Verify the correctness of static routing and IP forwarding
   
    

## Preparation for Routing Assignment

Before starting this assignment you should have read and understood chapter 4 in *Computer Networking: A Top Down Approach by Kurose-Ross*

For additional understanding check out the chapter 4 exercises at [http://wps.pearsoned.com/ecs_kurose_compnetw_6/216/55463/14198700.cw/index.html](http://wps.pearsoned.com/ecs_kurose_compnetw_6/216/55463/14198700.cw/index.html).
 
Also you should understand the topology you will be utilizing for this tutorial. It can be found [here] (http://groups.geni.net/geni/wiki/GENIEducation/SampleAssignments/IPRouting/Procedure).



## Preparation for utilizing the GENI environment

Make sure that before starting you have setup the correct topology and have the proper setup of SSH keys. The following videos will walk you through these steps.

- Part 1: [Understanding the GENI Portal](http://www.youtube.com/watch?v=H61s9sRP8Qk)
+ Part 2: [Setting up your SSH Keys](http://www.youtube.com/watch?v=3gssCqOvR-Q)
+ Part 3: [Reserving Resources](http://www.youtube.com/watch?v=1tFhi5ypCgg)



## Verification of Topology 

After establishing the slice on which the experiment will be executed, it should be verified for correctness. In this tutorial, we use an OMF experiment script that executes pings between neighbouring nodes.
This tutorial uses a [three-node topology] (https://raw.github.com/dbhat/VirtualCL/master/Assignments/IP%20forwarding/routetopology.png).
[![ScreenShot](https://raw.github.com/dbhat/VirtualCL/master/Assignments/IP%20forwarding/routetopology_video.png)](http://www.youtube.com/watch?v=Cjm2OIh9tyo)

The same experiment script can also be found in LabWiki. To run the experiment perform the following steps:

* Type "step1_threenode.rb" in the search box of the "Prepare widget" in LabWiki. Select the the script from the list of scripts that pops up.
* Drag the "notepad" icon from "Prepare" widget to the 
"Execute" widget.
* Check if all the specified parameters are correct.
* Start the experiment.



## Set up Routing and IP forwarding in Experiment Topology

In this step static routing is set up using route command and IP forwarding is enabled.

The same experiment script can also be found in LabWiki. To run the experiment perform the following steps:

* Type "step2_threenode.rb" in the search box of the "Prepare widget" in LabWiki. Select the the script from the list of scripts that pops up.
* Use the template and set up routing and enable IP forwarding.
* After making necessary changes in the template drag the "notepad" icon from "Prepare" widget to the 
"Execute" widget.
* Check if all the specified parameters are correct.
* Start the experiment.



## Verification of Routing and IP forwarding

After establishing the routing, we use an OMF experiment script that executes ping between node A and node C via node B, to verify the correctness of IP forwarding.

The same experiment script can also be found in LabWiki. To run the experiment perform the following steps:

* Type "step3_threenode.rb" in the search box of the "Prepare widget" in LabWiki. Select the the script from the list of scripts that pops up.
* Drag the "notepad" icon from "Prepare" widget to the 
"Execute" widget.
* Check if all the specified parameters are correct.
* Start the experiment.
