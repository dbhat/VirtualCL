# Fucntions of each file in the tool
This document explains the function of each file in the tool.

##index.html

This file is the UI of the Rspec generator. It contains fields to upload the number of servers, number of clients and upload their respective files. 

##rspecgenerator.py

This file generates the unique rpsec based on the user input. The user inputs are passed on to this python file and files to be uploaded are converted into archives. According to the number of servers and clients, server and client interfaces are added in the loop and the archive we created are included in the "install path". Then a file with a unique name is created and data is written into the file

##oedl.py

This file generates the unique oedl file which is used the verify if the resources are up and running.
