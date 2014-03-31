class LoadBalancer < Controller
    @@OUTBOUND_PRIO = 1 # Not really important
    @@OTHER_PRIO = 2
    @@UNKNOWN_PRIO = 5
    @@TUPLE_PRIO = 10
    @@TIMEOUT = 12

  def start
    info "OpenFlow Load Balancer Controller Started!"
    @left = nil
    @right = nil
    @outside = nil

    @stats_period = 10
    @got_stats = 0
    @left_flow = 0
    @left_packet = 0
    @left_byte = 0
    @right_flow = 0
    @right_packet = 0
    @right_byte = 0
    
    @last = :left

    File.open('/tmp/portmap') do |f|
      f.each do |l|
        name, number = l.chomp.split(' ')
        case name
        when 'left'
          @left = number.to_i
        when 'right'
          @right = number.to_i
        when 'outside'
          @outside = number.to_i
        else
          $stderr.puts "Unrecognized port '#{name}'"
          exit 1
        end
      end
    end
    if not @left or not @right or not @outside
      $stderr.puts "Missing port in /tmp/portmap, require left, right, outside"
      exit 1
    end

    # Erase the contents of the stat file
    File.open('/tmp/flowstats.out', 'w') {|file| file.truncate(0); file.close() }
  end

  def switch_ready(datapath_id)
    info "Switch is Ready: Switch id: #{datapath_id}"
    @dpid_stats = datapath_id
    add_timer_event :query_stats, @stats_period, :periodic


        # Send all outbound traffic to @outside without prejudice
        send_flow_mod_add(datapath_id, :priority => @@OUTBOUND_PRIO,
                          :match => Match.new(:in_port => @left),
                          :actions => ActionOutput.new(@outside))
        send_flow_mod_add(datapath_id, :priority => @@OUTBOUND_PRIO,
                          :match => Match.new(:in_port => @right),
                          :actions => ActionOutput.new(@outside))
        # Just send non-TCP inbound traffic ... wherever
        send_flow_mod_add(datapath_id, :priority => @@OTHER_PRIO,
                          :match => Match.new(:dl_type => 0x0800,
                                              :in_port => @outside),
                          :actions => ActionOutput.new(@left))
        send_flow_mod_add(datapath_id, :priority => @@OTHER_PRIO,
                          :match => Match.new(:dl_type => 0x0806,
                                              :in_port => @outside),
                          :actions => ActionOutput.new(@right))
        # New inbound TCP flows go to the controller
        send_flow_mod_add(datapath_id, :priority => @@UNKNOWN_PRIO,
                          :match => Match.new(:dl_type => 0x800,
                                              :nw_proto => 6,
                                              :in_port => @outside),
                          :actions => ActionOutput.new(OFPP_CONTROLLER))
    end

    def packet_in(datapath_id, message)
        # Throw out anything we don't recognize
        return if not message.ipv4? or not message.tcp?
        
        # Get path decision
        path = decide_path()
        
        send_flow_mod_add(datapath_id, :priority => @@TUPLE_PRIO,
                          :match => Match.new(:dl_type => 0x0800,
                                              :nw_proto => 6,
                                              :nw_src => message.ipv4_saddr,
                                              :nw_dst => message.ipv4_daddr,
                                              :tp_src => message.tcp_src_port,
                                              :tp_dst => message.tcp_dst_port,
                                              :in_port => @outside),
                          :actions => ActionOutput.new(path),
                          :idle_timeout => @@TIMEOUT)


        if message.total_len > 63
          send_packet_out(datapath_id, :packet_in => message,
                        :actions => ActionOutput.new(path))
        end
    end
    
  def query_stats
      send_message(@dpid_stats,
          FlowStatsRequest.new(
          :match => Match.new({:dl_type => 0x800, :nw_proto => 6}))
      )
  end

  def stats_reply (datapath_id, message)
    info "[stats_reply]-------------------------------------------"
    left_returned = 0
    right_returned = 0
    left_byte_count = 0
    left_packet_count = 0
    left_flow_count = 0
    right_byte_count = 0
    right_packet_count = 0
    right_flow_count = 0
    #average per-flow throughput is calculated by sum_throughput/num_flows for each path
    left_total_throughput = 0
    right_total_throughput = 0
    left_avg_throughput = 0
    right_avg_throughput = 0

    flow_count = message.stats.length
    if(flow_count != 0)
      message.stats.each do | flow_msg |
        #info "packet count is "+flow_msg.packet_count.to_s
        #info "byte count is "+flow_msg.byte_count.to_s
        #info "port number is "+flow_msg.actions[0].port.to_s
        if(flow_msg.actions[0].port_number == @left && flow_msg.duration_sec != 0)
            left_returned = 1
            left_flow_count += 1
            left_byte_count += flow_msg.byte_count
            left_packet_count += flow_msg.packet_count
            if flow_msg.duration_sec + flow_msg.duration_nsec/1000000000 != 0
              left_total_throughput += (flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000))
              info "===left path flow #{left_flow_count.to_s} throughput: #{left_total_throughput} Bps"
            end
        elsif (flow_msg.actions[0].port_number == @right && flow_msg.duration_sec != 0)
            right_returned = 1
            right_flow_count += 1
            right_byte_count += flow_msg.byte_count
            right_packet_count += flow_msg.packet_count
            if flow_msg.duration_sec + flow_msg.duration_nsec/1000000000 != 0
              right_total_throughput += (flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000))
              info "+++right path flow #{right_flow_count.to_s} throughput: #{right_total_throughput} Bps"
            end
        end
      end
    end
    file = File.open("/tmp/flowstats.out", "a")
    if (left_returned == 1) 
        @left_flow = left_flow_count
        @left_packet = left_packet_count
        @left_byte = left_byte_count
        if left_flow_count !=0
          left_avg_throughput = left_total_throughput/left_flow_count
        end
    end
    file.puts "left #{@left_flow} #{@left_byte} #{@left_packet} #{left_total_throughput} Bps #{left_avg_throughput} Bps"
    if (right_returned == 1) 
        @right_flow = right_flow_count
        @right_packet = right_packet_count
        @right_byte = right_byte_count
        if right_flow_count !=0 
          right_avg_throughput = right_total_throughput/right_flow_count
        end 
    end
    file.puts "right #{@right_flow} #{@right_byte} #{@right_packet} #{right_total_throughput} Bps #{right_avg_throughput} Bps"
    file.close
  end
 
 

    def decide_path()
        # Each TCP flow is assigned to a random path
        path = rand < 0.5 ? @left : @right
	if path == @right
            info "In random mode, go *Right* path this time"
        else
            info "In random mode, go *Left* path this time"
        end		
        return path
    end
end
