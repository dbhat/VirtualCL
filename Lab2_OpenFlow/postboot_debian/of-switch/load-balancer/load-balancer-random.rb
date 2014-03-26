class LoadBalancer < Controller
    @@OUTBOUND_PRIO = 1 # Not really important
    @@OTHER_PRIO = 2
    @@UNKNOWN_PRIO = 5
    @@TUPLE_PRIO = 10

    @@TIMEOUT = 300

    def start
        @left = nil
        @right = nil
        @outside = nil

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
    end

    def switch_ready(datapath_id)
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
