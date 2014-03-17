#defProperty('source1', 'omf.nicta.node11', 'ID of a resource')
#defProperty('source2', 'omf.nicta.node13', 'ID of a resource')
#defProperty('target', 'emmy9.casa.umass.edu/expect_wget_script.sh', 'download target1')
#defProperty('target1', 'emmy9.casa.umass.edu/expect_script.sh', 'download target2')

defGroup('Node1', "nodea-sample10")
defGroup('Node2', "nodeb-sample10")
defGroup('Node3', "nodec-sample10")
#defGroup('NeucaServices', "NodeA-sample4","NodeB-sample4","NodeC-sample4")


onEvent(:ALL_UP) do |event|
  after 1 do
  #allGroups.startApplications
  info 'Changing routing setup'
  
 # group('NeucaServices').exec("/usr/sbin/service neuca stop")

  group('Node1').exec("")
  group('Node1').exec("")

  group('Node2').exec("")

  group('Node3').exec("")
  group('Node3').exec("")

  info 'Routing setup finished'
  end

  after 10 do
  info 'Stopping applications'
  #allGroups.stopApplications
  end
  after 12 do
  Experiment.done
  end
end
