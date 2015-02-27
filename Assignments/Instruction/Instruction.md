Note: This is still a draft
#LABWIKI-Instructor's Instruction 

##Introduction:
LabWiki is a web-based tool developed at Nicta. It is used to design, describe and run experiments on GENI test bed and perform active measurements. 

##OEDL:
OEDL is a domain-specific language for the description of an experiment's execution. OEDL is based on the Ruby language, but provides its own set of experiment-oriented commands and statements.

For further details, visit
*	[http://mytestbed.net/projects/omf6/wiki/OEDLOMF6](http://mytestbed.net/projects/omf6/wiki/OEDLOMF6)

##Logging in LabWiki:
LabWiki webpage is available at [http://gimi6.casa.umass.edu:4000](http://gimi6.casa.umass.edu:4000) . Click on the "Login with GENI ID"
*	If you have already logged in to the GENI Portal, you will be automatically logged in to LabWiki
*	Use your GENI Portal username and password to login
*	You will be asked to agree on sending your GENI Portal information to LabWiki. LabWiki will only use your GENI ID to log you in, so please click on "Send my information"

Note:
If you are logged in to Geni portal, you are logged in to LabWiki as well. It is recommended to use chrome browser to access LabWiki. In other browsers, the graphs in LabWiki may not be displayed properly due to some issues in JavaScript used in LabWiki.

##Structure of LabWiki:
LabWiki consists of three panels namely: Plan, Prepare and Execute. 

##Plan:
This panel is used to view Markdown scripts. This column is usually used to provide some instructions on the experiment. This is also the place where you describe for example, the goals of the experiment, the hypotheses that it tests,  its design, any background information to help understand it. When the experiment is finished, the graphs can be dragged and dropped in to this panel to take a look. To open a document, start typing its name in the search box below the column's title. You can choose the required one from the drop down list that shows the matching documents.

##Prepare:
This column can be used to create and edit two type of documents: 
*	Markdown scripts that can be viewed on the plan column
*	OEDL  documents that have the experiment scripts written in Ruby.


A new document can be created by clicking on the "+" button below the column's title. You will have the option of choosing either the "wiki" option or "oedl" option. "wiki" option should be chosen for markdown scripts. Also, a document opened in the plan column can be dragged and dropped in to this column for editing. Click save icon to save the document.

To edit a document, start typing in the search box below the column's title. A drop down list consisting of matching results will be displayed. The experiment scripts will have either .oedl or .rb file extension whereas the markdown scripts will have .md extension.

##Execute:
This panel is used to start a new instance of an experiment, monitor the execution, view the logs and graphs. 
*	To start a new instance of an experiment, select and load the experiment in the Prepare column as described above. If required you may want to edit and save that experiment
*	Then drag the icon   next to the experiment's name from the Prepare column, and drop it in the Execute column. You should now see in the Execute column some information about this new experiment instance.
*	In addition to standard experiment parameters (e.g. Name, Slice, Scripts), all configurable experiment properties are displayed in the Execute column , where you can change their default values.
*	You may want to give a name to this experiment instance in the Name field within the Execute column, or leave that field blank to let LabWiki pick a unique name for you.
*	You can start this new experiment instance by clicking on the "Start Experiment" button.
*	Once you start this new experiment instance, the Execute column will show information about the running experiment, such as detailed logs and any defined graphs (you may have to scroll down to the bottom of the Execute column to see these graphs)
*	When the experiment instance has finished running, you may copy a plotted graph from the Execute column back to the Plan column, in order to include it to your report or written records. To do so, drag the icon   located below the graph (next to its title) and drop it just after the line of text of your choice in the Plan column

##Key Features of LabWiki:
LabWiki can be used to run experiments which:
*	dynamically react to changes in the resources being used.
*	dynamically react to collected measurements.
*	automatically retrieves provisioned resources from LabWiki's Topology Editor.

Labwiki now provides SSH Access to LabWiki Managed Git Repository with the help of Gitolite. By integrating with Gitolite, LabWiki now allows end users to access and update git repositories via standard git command. They could now use their favorite text editor to create and modify experiment scripts; use normal git work flow to synchronize changes. Gitolite need not be installed on the same server as Geni.
Labwiki can used to automatically grade the students' experiments. 
With these basics, let us see how to use LabWiki with an example. 
Let us take the Learning switch assignment for example. 

Brief information on Learning switch assignment:

The goal of this assignment is to implement the learning switch capability that is used by Ethernet switches by using a software-based OpenFlow switch. In the topology shown in the figure, this software switch is to be implemented in node “switch”. All the other nodes represent regular hosts. To realize this implementation of a learning switch it is your task to implement and trema-based OpenFlow controller. You will have to verify the correct functionality of the learning switch by creating an experiment script in which any node A pings nodes B – node E in LabWiki.
As the purpose of this instruction is to learn about LabWiki, let us not delve into detail about how to set up the assignment on Geni Portal. The instructions assume that the topology has already been set up on Geni portal. 

Step 1:
Now, as the first step, we need to see the instructions on how to run the experiment and see some information about the experiment. These things would be written on a MarkDown file. To view such file, place the cursor on the search box in the 'plan' panel and start typing the name of the required file. This would give you a drop-down list of experiments. Choose the one you need and it will be similar to the one shown in figure a. 
 
Figure a.

Step 2:
The next step is to write oedl scripts to run the experiment. Place the cursor in the search box in the 'Prepare' panel and start typing the name of the required file. Choose the required file from the drop-down list. In general, a template will be provided to the students in which they have to implement certain functionalities. It will similar to the one shown in figure b. The script shown in the figure just verifies if the learning switch functionality is implemented properly. It has functions that send pings between different nodes. It also has a function for building the graph which you can plot based on many different metrics.
   
Figure b.
Step 3:
The next step is to run the script that we wrote on the Prepare column. Just drag and drop the    icon from the Prepare column to the execute column. See figure c. to get a better idea.  

Figure c.

You fill have the following options: 
* You can give a name to the experiment that you are gonna run. This will be useful for retrieving the stored experiment logs.
* You can choose the project that the current experiment belongs to. If you are a member of different projects on Geni portal, they will appear on the drop-down list.
* You will have an option to choose experiment context.
* You can choose the slice that the experiment belongs to in the Geni Portal.
* After dragging and dropping the icon, the script will be parsed and the fields like different node and their IP addresses will be displayed in the Execute column. After verifying these details, click "Start Experiment" button.
After starting the experiment, the experiment will be initially in the 'pending' state as shown in figure which will change to 'running' in a few seconds. You can also type the name of the experiment in the search box. Note down the experiment name when the experiment is in the 'pending' state. You can retrieve the logs even after a few days. You have an option to stop the experiment. Click the square shaped black button to stop the experiment See Figure d. and Figure e. 
 
Figure d.
 
 
Figure e.


Once the experiment is finished, you can see all the logs and check where it has failed. If the experiment has run successfully, you would see a graph being plotted. You can drag and drop the graph into 'Plan' column to get a better look. You will also have an option to dump the state to IRODS. You can retrieve the logs from IRODS later. See Figure f.
 
Figure f.

#GENI portal

## Preparation for utilizing the GENI environment

Make sure that before starting you have setup the correct topology and have the proper setup of SSH keys. The following videos will walk you through these steps.

- Part 1: [Understanding the GENI Portal](http://www.youtube.com/watch?v=H61s9sRP8Qk)
+ Part 2: [Setting up your SSH Keys](http://www.youtube.com/watch?v=3gssCqOvR-Q)
+ Part 3: [Reserving Resources](http://www.youtube.com/watch?v=1tFhi5ypCgg)

