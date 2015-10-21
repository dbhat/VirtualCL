import socket   #for sockets
import sys  #for exit
 
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error:
    print 'Failed to create socket'
    sys.exit()
     
print 'Socket Created'
 
port = 8888;
remote_ip = "192.168.1.1"
  
#Connect to remote server
s.connect((remote_ip , port))
 
print 'Socket Connected to ' + remote_ip
 
#Send some data to remote server
message = '(2,1)'
 
try :
    #Set the whole string
    s.sendall(message)
except socket.error:
    #Send failed
    print 'Send failed'
    sys.exit()
 
print 'Message send successfully'
 
#Now receive data
reply = s.recv(4096)
 
print reply
s.close()
