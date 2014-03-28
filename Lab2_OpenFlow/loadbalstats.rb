
defProperty('intervalcol',"1", "Interval to Tail")
defProperty('theSender', "outside-lbeg", "ID of sender node")
defProperty('theReceiver', "inside-lbeg", "ID of receiver node")
defProperty('theSwitch',"switch-lbeg", "ID of switch node")
defProperty('pathfile', "/tmp/flowstats.out", "Path to file")
defGroup('Sender', property.theSender)
defGroup('Receiver', property.theReceiver)

defApplication('iperfserv') do |app|
  app.description = "manually run Iperf server"
  app.binary_path = "/usr/bin/iperf -s"
end
defApplication('iperfclient') do |app|
  app.description = "manually run Iperf client"
  app.binary_path = "/usr/bin/iperf -c 10.10.10.2 -t 800 -P 5"
end

defApplication('ofstats') do |app|
  app.description = 'Simple Definition for the of-collect application'
  # Define the path to the binary executable for this application
  app.binary_path = '/usr/local/bin/ofcollect.rb'
  app.defProperty('target', 'Address to output file', '-f', {:type => :string})
  app.defProperty("interval","Interval",'-i', {:type => :string})
  app.defMeasurement('wrapper_ofthroughput') do |m|
    m.defMetric(':pathtype', :string)
    m.defMetric('throughput',:int64)
    m.defMetric('instput',:int64)
  end
end
defGroup('Source1', property.theSwitch) do |node|
  node.addApplication("ofstats") do |app|
    app.setProperty('target', property.pathfile)
    app.setProperty('interval', property.intervalcol)
    app.measure('wrapper_ofthroughput', :samples => 1)
  end
end
  defGroup('Sender1', property.theSender) do |node|
    node.addApplication("iperfclient") do |app|
    end
  end
  defGroup('Sender2', property.theSender) do |node|
    node.addApplication("iperfclient") do |app|
    end
  end
  defGroup('Receiver', property.theReceiver) do |node|
    node.addApplication("iperfserv") do |app|
    end
  end

onEvent(:ALL_UP) do |event|
  info "Starting the collect"
  after 2 do
    group('Receiver').startApplications
  end
  after 8 do
    group('Sender1').startApplications
    group('Source1').startApplications
  end
  after 40 do
  	group('Sender2').startApplications
  end
  after 200 do
    info "Stopping the collect"
    allGroups.stopApplications
    #group('Receiver').exec("iperf killall")
    Experiment.done
  end
end

defGraph 'Throughput' do |g|
  g.ms('wrapper_ofthroughput').select(:oml_ts_client, :throughput, :pathtype) 
  g.caption "Throughput of Flows"
  g.type 'line_chart3'
  g.mapping :x_axis => :oml_ts_client, :y_axis => :throughput, :group_by => :pathtype
  g.xaxis :legend => 'oml_ts'
  g.yaxis :legend => 'Throughput', :ticks => {:format => 's'}
end
#defGraph 'InstantaneousThroughput' do |g|
 # g.ms('wrapper_ofthroughput').select(:oml_ts_client, :instput, :pathtype) 
 # g.caption "Throughput of Flows"
 # g.type 'line_chart3'
 # g.mapping :x_axis => :oml_ts_client, :y_axis => :instput, :group_by => :pathtype
 # g.xaxis :legend => 'oml_ts'
 # g.yaxis :legend => 'Instantaneous Throughput', :ticks => {:format => 's'}
#end

