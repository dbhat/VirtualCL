#!/usr/bin/env python
'''
This is a Python script which is used to automate login to GENI resources using geni-lib
(https://media.readthedocs.org/pdf/geni-lib/latest/geni-lib.pdf) and
run remote shell commands on them using Paramiko, a Python SSH-client library. 
'''

import socket
socket.setdefaulttimeout(5)
 
import subprocess 
import paramiko
import sys
import threading
import os
import time

import geni.util
import geni.aggregate.instageni as IG #Use geni.aggregate.exogeni for EG VMs

context = geni.util.loadContext()

slicename = "myslice" #Replace with your slicename
agg_name = "myagg"  #Replace with your aggregate

user = 'myusername' #Replace with your username

test_clip = []
test_clport = []
test_clhost = []
 
test_servip = []
test_servport = []
test_servhost = []

test_crossip = []
test_crossport = []
test_crosshost = [] 
def cross_server(ipaddress,ports):
    global user
     
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(ipaddress,username=user,port=ports)
    except paramiko.AuthenticationException:
        print "[-] Authentication Exception! ..."      
         
    except paramiko.SSHException:
        print "[-] SSH Exception! ..." 
         
    works = ipaddress.strip('\n')+','+user  
    print '[+] '+ works
    stdin, stdout, stderr = ssh.exec_command("ls -l /users/") #Insert command here
    print stdout.read()
    print stderr.read()
    ssh.close()
def cross_client(ipaddress,ports,exec_commands):
    global user
     
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(ipaddress,username=user,port=ports)
    except paramiko.AuthenticationException:
        print "[-] Authentication Exception! ..."      
         
    except paramiko.SSHException:
        print "[-] SSH Exception! ..." 
         
    works = ipaddress.strip('\n')+','+user  
    print '[+] '+ works

    stdin, stdout, stderr = ssh.exec_command("ls -l /users/") #Insert command here
    print stdout2.read()
    ssh.close()
def app_client(ipaddress,ports):
    global user
     
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(ipaddress,username=user,port=ports)
    except paramiko.AuthenticationException:
        print "[-] Authentication Exception! ..."      
         
    except paramiko.SSHException:
        print "[-] SSH Exception! ..." 
         
    works = ipaddress.strip('\n')+','+user  
    print '[+] '+ works
    stdin, stdout, stderr = ssh.exec_command("ls -l /users/") #Insert command here
    print stderr.read()
    print stdout.read()
    ssh.close()
    
if __name__ == "__main__": 

	login_list = geni.util.printlogininfo(context=context, slice=slicename, am=IG.UtahDDC) #Replace aggregate for geni-lib here
	
	for line in login_list:
		if line[1] == "myuser": #
			if "client" in line[0]:
				test_clip.append(line[2])
				test_clport.append(line[3])
				test_clhost.append(line[0])
			if "cross" in line[0]:
				test_crossip.append(line[2])
				test_crossport.append(line[3])
				test_crosshost.append(line[0])
			if "cache" in line[0]:
				test_servip.append(line[2])
				test_servport.append(line[3])
				test_servhost.append(line[0])
			
			
	for item in test_clip, test_clport, test_clhost:
		print item
	print "\n\n"
	
	for item in test_crossip, test_crossport, test_crosshost:
		print item
	print "\n\n"
	
	for item in test_servip, test_servport, test_servhost:
		print item
	print "\n\n"
	
	
	try:
		'''
		Run commands on three sets of resources in a setup. All commands can be sequentially executed using the sleep API of the time class in Python
		
		
		'''
		count=0
		while count<len(test_servip):
				threading.Thread(target=cross_server,args=(str(test_servip[count]),int(test_servport[count]))).start()
				time.sleep(1.0)
				count+=1
		time.sleep(5.0)
		
		count=0
		while count<len(test_crossip):
				threading.Thread(target=cross_client,args=(str(test_crossip[count]),int(test_crossport[count]),str(exec_commands[count]))).start()
				time.sleep(2.0)
				count+=1
		
		count=0
		while count<len(test_clip):
				threading.Thread(target=app_client,args=(str(test_clip[count]),int(test_clport[count]))).start()
				time.sleep(4.0)
				count+=1
		
		
	except Exception, e:
		print '[-] General Exception'
	
