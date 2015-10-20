import sys
target = open("oedl/sample.oedl", 'w')
Sourcename = sys.argv[1]
Source = sys.argv[2]
tot = int(sys.argv[3])
print "\nThe oedl file is located at: http://emmy10.casa.umass.edu/oedl/sample.oedl"

def addproperty(total):
        target.write("defProperty('resource1', 'switch', 'ID of a resource')\n")
        for idx in range(total,2*total):
                target.write("defProperty('sinkaddr1"+ str(idx-total+1) + "', '192.168.1." + str(idx+1) + "', 'Ping destination address')\n")
				
def adddefgroup(sourcename,source):
        target.write("defGroup(" + sourcename + "," + source + ") do |node|\n")
        addnode()
        addonevent(sourcename)
        target.write("end\n")
		
def addnode():
        count = 1
        for idx in range(0,tot):
                count = count +1
                target.write("\tnode.addApplication(\"" + "ping"+ "\") do |app|\n")
                #node.addApplication("ping") do |app|
                target.write("\t\tapp.setProperty('target',property.sinkaddr1"+ str(count)+")\n")
                #app.setProperty('target', property.sinkaddr12)
                target.write("\t\tapp.setProperty('count', 30)\n")
                target.write("\t\tapp.measure('ping', :samples => 1)\n")
                target.write("\tend\n")
				
def addgraph():
        target.write("def addGraph 'RTT' do |g|\n\tg.ms('ping').select(:oml_seq, :remote, :rtt)\n\
\tg.caption 'RTT of received packets'\n\
\tg.type 'line_chart3'\n\
\tg.mapping :x_axis => :oml_seq, :y_axis => :rtt, :group_by => :remote\n\
\tg.xaxis :legend => 'oml_seq'\n\
\tg.yaxis :legend => 'rtt', :ticks => {:format => 's'}\n\
end\n")

def addping():
        target.write("defApplication('ping') do |app|\n\
\tapp.description = 'Simple Definition for the ping-oml2 application'\n\
\t#Define the path to the binary executable for this application\n\
\tapp.binary_path = '/usr/local/bin/ping-oml2'\n\
\t#Define the configurable parameters for this application\n\
\t#For example if target is set to foo.com and count is set to 2, then the\n\
\t#application will be started with the command line:\n\
\t#/usr/bin/ping-oml2 -a foo.com -c 2\n\
\tapp.defProperty('target', 'Address to ping', '-a', {:type => :string})\n\
\tapp.defProperty('count', 'Number of times to ping', '-c', {:type => :integer})\n\
\t# Define the OML2 measurement point that this application provides.\n\
\t# Here we have only one measurement point (MP) named 'ping'. Each measurement\n\
\t# sample from this MP will be composed of a 4-tuples (addr,ttl,rtt,rtt_unit)\n\
\tapp.defMeasurement('ping') do |m|\n\
\t\tm.defMetric('remote',:string)]\n\
\t\tm.defMetric('ttl',:uint32)\n\
\t\tm.defMetric('rtt',:double)\n\
\t\tm.defMetric('rtt_unit',:string)\n\
\tend\n\
end\n")

def addonevent(Source):
        target.write("onEvent(:ALL_UP_AND_INSTALLED) do |event|\n\
\tinfo 'Starting the ping'\n\
\tafter 30 do\n\
\t\tgroup('" + Source + "').startApplications\n\
\tend\n\
\tafter 80 do\n\
\t\tinfo 'Stopping the ping'\n\
\t\tallGroups.stopApplications\n\
\t\tExperiment.done\n\
\tend\n\
end\n")
addproperty(tot)
adddefgroup(Sourcename, Source)
addping()
addgraph()
target.close()
