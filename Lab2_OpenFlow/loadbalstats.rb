defProperty('slice', 'loadbal', "slice name")
defProperty('intervalcol',"1", "Interval to Tail")
defProperty('theSender', "outside", "ID of sender node")
defProperty('theReceiver', "inside", "ID of receiver node")
defProperty('theSwitch',"switch", "ID of switch node")
defProperty('pathfile', "/tmp/flowstats.out", "Path to file")

theSender = property.theSender.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
theReceiver = property.theReceiver.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
theSwitch = property.theSwitch.value.to_s.split(',').map { |x| "#{x}-#{property.slice}" }
iperfNodes = theSender + theReceiver

defApplication('clean_iperf') do |app|
  app.description = 'Some commands to ensure that we start with a clean slate'
  app.binary_path = '/usr/bin/killall -s9 iperf; '
  app.quiet = true
end

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
    m.defMetric('pathtype', :string)
    m.defMetric('throughput',:int64)
    m.defMetric('avgperflow',:int64)
  end
end

defGroup('iperf_nodes', *iperfNodes) do |g|
  g.addApplication("clean_iperf") do |app|
  end
end

defGroup('Source1', *theSwitch) do |node|
  node.addApplication("ofstats") do |app|
    app.setProperty('target', property.pathfile)
    app.setProperty('interval', property.intervalcol)
    app.measure('wrapper_ofthroughput', :samples => 1)
  end
end

  defGroup('Sender1', *theSender) do |node|
    node.addApplication("iperfclient") do |app|
    end
  end
  defGroup('Sender2', *theSender) do |node|
    node.addApplication("iperfclient") do |app|
    end
  end
  defGroup('Sender3', *theSender) do |node|
    node.addApplication("iperfclient") do |app|
    end
  end
  defGroup('Receiver', *theReceiver) do |node|
    node.addApplication("iperfserv") do |app|
    end
  end
  

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  info "Starting the collect"
  group('iperf_nodes').startApplications
  after 2 do
    group('Receiver').startApplications
  end
  after 15 do
    group('Sender1').startApplications
    group('Source1').startApplications
  end
  after 40 do
    group('Sender2').startApplications
  end
  after 80 do
    group('Sender3').startApplications
  end
  after 200 do
    info "Stopping the collect"
    allGroups.stopApplications
    Experiment.done
  end
end

defGraph 'Throughput' do |g|
  g.ms('wrapper_ofthroughput').select(:oml_ts_client, :throughput, :pathtype) 
  g.caption "Throughput of Flows"
  g.type 'line_chart3'
  g.mapping :x_axis => :oml_ts_client, :y_axis => :throughput, :group_by => :pathtype
  g.xaxis :legend => 'Time[s]'
  g.yaxis :legend => 'Throughput [bps]', :ticks => {:format => 's'}
end
defGraph 'ThroughputperFlow' do |g|
  g.ms('wrapper_ofthroughput').select(:oml_ts_client, :avgperflow, :pathtype) 
  g.caption "Average Throughput of Flows"
  g.type 'line_chart3'
  g.mapping :x_axis => :oml_ts_client, :y_axis => :avgperflow, :group_by => :pathtype
  g.xaxis :legend => 'Time [s]'
  g.yaxis :legend => 'Average per Flow [bps]', :ticks => {:format => 's'}
end

