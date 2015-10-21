import socket
import sys
def filewrite(client, result):
        print client, result
        with open("hello1.txt") as f:
                data1 = f.readlines()
                print data1
                str = "(" + client
        for idx, val in enumerate(data1):
                if str in val:
                        data1[idx] = "(" + client + "," + result + ")\n"
                        print data1[idx]
        print data1
        with open("hello1.txt","w") as f:
                for idx, val in enumerate(data1):
                        f.write(val)
HOST = ''   # Symbolic name meaning all available interfaces
PORT = 8888 # Arbitrary non-privileged port
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'Socket created'
try:
    s.bind((HOST, PORT))
except socket.error , msg:
    print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit()
print 'Socket bind complete'
s.listen(10)
print 'Socket now listening'
#now keep talking with the client
with open("hello1.txt", "w") as f:
        f.write("(2,0)\n")
        f.write("(3,0)\n")
while 1:
    #wait to accept a connection - blocking call
    conn, addr = s.accept()
    print 'Connected with ' + addr[0] + ':' + str(addr[1])
    data = conn.recv(1024)
    print data
    reply = 'OK...' + data
    if ((len(data) == 5)and(data[0] == '(')and(data[4] == ')')):
        print 'valid request'
		if (data[1] == '2'):
                        client = data[1]
                        result = data[3]
                        filewrite(data[1], data[3])
        if (data[1] == '3'):
                        client = data[1]
                        result = data[3]
                        filewrite(data[1], data[3])
    if not data:
        break
    conn.sendall(reply)
conn.close()
s.close()
