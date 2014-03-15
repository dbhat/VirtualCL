defProperty('source1', "nodea-sample4", "ID of a resource")
defProperty('source2', "nodeb-sample4", "ID of a resource")
defProperty('source3', "nodec-sample4", "ID of a resource")
#defProperty('graph', true, "Display graph or not")



defProperty('sinkaddr13', '192.168.2.12', "Ping destination address")




defApplication('ping') do |app|
  app.description = 'Simple Definition for the ping-oml2 application'
  # Define the path to the binary executable for this application
  app.binary_path = '/usr/local/bin/ping-oml2'
  # Define the configurable parameters for this application
  # For example if target is set to foo.com and count is set to 2, then the 
  # application will be started with the command line:
  # /usr/bin/ping-oml2 -a foo.com -c 2
  app.defProperty('target', 'Address to ping', '-a', {:type => :string})
  app.defProperty('count', 'Number of times to ping', '-c', {:type => :integer})
  # Define the OML2 measurement point that this application provides.
  # Here we have only one measurement point (MP) named 'ping'. Each measurement
  # sample from this MP will be composed of a 4-tuples (addr,ttl,rtt,rtt_unit)
  app.defMeasurement('ping') do |m|
    m.defMetric('dest_addr',:string)
    m.defMetric('ttl',:uint32)
    m.defMetric('rtt',:double)
    m.defMetric('rtt_unit',:string)
  end
end
defGroup('Source1', property.source1) do |node|
  node.addApplication("ping") do |app|
    app.setProperty('target', property.sinkaddr13)
    app.setProperty('count', 30)
    #app.setProperty('interval', 1)
    app.measure('ping', :samples => 1)
  end
end






#defGroup('Sink1', property.sink1) do |node|
#end

#defGroup('Sink2', property.sink2) do |node|
#end

#defGroup('Sink3', property.sink3) do |node|
#end

#defGroup('Sink4', property.sink4) do |node|
#end

#defGroup('Sink5', property.sink5) do |node|
#end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  info "Starting the ping"
  after 5 do
    allGroups.startApplications
  end
  after 70 do
    info "Stopping the ping"
    allGroups.stopApplications
    Experiment.done
  end
end

defGraph 'RTT' do |g|
  g.ms('ping').select(:oml_seq, :dest_addr, :rtt) 
  g.caption "RTT of received packets."
  g.type 'line_chart3'
  g.mapping :x_axis => :oml_seq, :y_axis => :rtt, :group_by => :dest_addr
  g.xaxis :legend => 'oml_seq'
  g.yaxis :legend => 'rtt', :ticks => {:format => 's'}
end
