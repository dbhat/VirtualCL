import geni.aggregate.instageni as ig
import geni.rspec.pg as pg
import sys
import tarfile
import uuid
rspec = pg.Request()
IP = "192.168.1.%d"
client_interface_list = []
server_interface_list = []
count = 0
Num_of_servers = int(sys.argv[1])
Num_of_clients = int(sys.argv[2])
Server_path ="http://emmy10.casa.umass.edu/" +sys.argv[3] + ".tar.gz"
Client_path = "http://emmy10.casa.umass.edu/" +sys.argv[5] + ".tar.gz"
archive = tarfile.open(sys.argv[3] + ".tar.gz", "w|gz")
archive.add(sys.argv[3], arcname= sys.argv[4])
archive.addfile(tarfile.TarInfo(sys.argv[3]), file(sys.argv[3]))
archive.close()
archive = tarfile.open(sys.argv[5] + ".tar.gz", "w|gz")
archive.add(sys.argv[5], arcname= sys.argv[6])
rspec_path ="rspec/" + str(uuid.uuid4()) + ".xml"
#Server_path = "http://emmy10.casa.umass.edu"
#Client_path = "http://emmy10.casa.umass.edu"
#rspec_path = "test3.xml"
for idx in range(0,Num_of_servers):
        count = count+1
        server = pg.XenVM("server%d" % (idx))
        server_iface = server.addInterface("if%d" % (count))
        server_iface.addAddress(pg.IPv4Address(IP % (count), "255.255.255.0"))
        server_interface_list.append(server_iface)
        server.disk_image = "https://www.instageni.illinois.edu/image_metadata.php?uuid=03c883b6-53f9-11e4-9608-000000000000"
        server.addService(pg.Install(path="/", url = "http://emmy9.casa.umass.edu/GEC-20/gimidev.tar.gz"))
        server.addService(pg.Install(path="/", url = Server_path))
        server.addService(pg.Execute(shell="sh", command = "sudo sh /gimidev/gimibot.sh"))
        server.addService(pg.Execute(shell="sh", command = "sudo apt-get update; sudo apt-get install -y apache2"))
        rspec.addResource(server)
		
for idx in range(0,Num_of_clients):
        count = count+1
        client = pg.XenVM("client%d" % (idx))
        client_iface = client.addInterface("if%d" % (count))
        client_iface.addAddress(pg.IPv4Address(IP % (count), "255.255.255.0"))
        client_interface_list.append(client_iface)
        client.disk_image = "https://www.instageni.illinois.edu/image_metadata.php?uuid=03c883b6-53f9-11e4-9608-000000000000"
        client.addService(pg.Install(path="/", url = "http://emmy9.casa.umass.edu/GEC-20/gimidev.tar.gz"))
        client.addService(pg.Install(path="/", url = Client_path))
        client.addService(pg.Execute(shell="sh", command = "sudo sh /gimidev/gimibot.sh"))
        rspec.addResource(client)
count = 0
for s in range(0,Num_of_servers):
        for c in range(0,Num_of_clients):
                count = count+1;
                link = pg.LAN("lan%d" % (count))
                link.addInterface(server_interface_list[s])
                link.addInterface(client_interface_list[c])
                rspec.addResource(link)
rspec.write(rspec_path)
print "rspec created"
print "rspec is located at"
print "http://emmy10.casa.umass.edu/" + rspec_path
