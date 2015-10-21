# Multi-casting Assignment

This course module gives an intuition behind how the multi-casting works in real-time.

*  Students will be given a template of the controller where certain functionalities like controller logic for packet duplication will be implemented.
*  Overall, students will learn the multi-casting protocol, packet duplication, layer-2 ping application
*  Assignments will be run through LabWiki and students can visualize the working through graphs and debug using the logs.

## Preparation for utilizing Geni Environment

Make sure that before starting you have setup the correct topology and have the proper setup of SSH keys. The following videos will walk you through these steps.

- Part 1: [Understanding the Geni Portal](http://www.youtube.com/watch?v=H61s9sRP8Qk)
+ Part 2: [Setting up your SSH Keys](http://www.youtube.com/watch?v=3gssCqOvR-Q)
+ Part 3: [Reserving Resources](http://server.casa.umass.edu/~zink/ECE374/recordings/assign1_topo_setip.mp4)

In the case of this assignment the only thing that is different is the name of the RSpec you have to choose. So instead of using “ECE3743Node” (as shown around 1:50 minutes into the video) you now have to use RSpec titled “IG-learning-switch” 


## Working

A 5-node topology is used for this purpose. Three nodes are clients, one node is the server and the other node is the switch. In this assignment, to show the functionality of multi-casting, layer 2 ping application is used. Server will multicast only to the subscribed clients. Separate applications run on clients and servers for the purpose of sending and receiving join/leave messages. The server application initially creates a file called "hello1.txt". It writes the default values for all the available clients. '0' represents not being subscribed while '1' represents being subscribed. The default value is '0'. Each line in the file is in the format "(client_number, 0/1)". When a client send a join message(1) to the server, the server will modify the appropriate entry in "hello1.txt". This file is used by the controller to get the list of subscribed clients. When clients make a layer-2 ping request, server will make multiple copies depending on the number of subscribed clients and only those subscribed clients will receive the reply back from the server.

## Set up the multi-cast assignment

* The first step is to download the controller, server and client applications:

>emmy9.casa.umass.edu/multicastcontroller.rb
 
>emmy9.casa.umass.edu/serverapp.py

>emmy9.casa.umass.edu/clientapp.py

 The controller file should be downloaded on the switch node, the server application on the server node and client application on the remaining nodes

* Run the server application on the server using the command:
>python serverapp.py "0"

* Run the client application on the clients using the command:
>python clientapp.py "1"

 "1" denotes a join message. For a leave message, send "0" as command line argument.

## Verification of multi-casting functionality

 * You can start the controller with the following command: 
 
>trema run multicastcontroller.rb
 * After you have started the controller switch over to LabWiki. Download the script "multicast.oedl" from emmy9.casa.umass.edu/multicastcontroller.oedl. Make necessary changes if needed and run the experiment on Labwiki. This oedl script runs a layer-2 ping application. From the graph, you can see the data transfer only between the server and the subscribed clients. 



