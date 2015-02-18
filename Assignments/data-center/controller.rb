require "fdb"
class LoadBalancer < Controller
$H = Hash[1 => "192.168.1.15", 4 => "192.168.1.15"]
$H1 = Hash[]
$path = 1
$test
$destination_address = "192.168.1.6"
$flag = false

  @stats_period = 1
 add_timer_event :query_stats, @stats_period, :periodic
        def start
                info "OpenFlow LoadBalancer Controller Started"
                @one = 1
                @two = 2
                @three = 3
                @four = 4
                @last = :one
#               @H = Hash["1" => "192.168.1.6", "4" => "192.168.1.7"]
               # info "#{H['1']}"
                @fdb=FDB.new
        end
        def switch_ready(datapath_id)
        info "Switch is Ready! Switch id: #{datapath_id}"
	@my_switch = datapath_id
        end
	def query_stats
                        if @my_switch != nil
                    	info "my switch is #{@my_switch}"
			puts "Querying stats--------------------------------"
                send_message(@my_switch,
                        FlowStatsRequest.new(:match => Match.new({:dl_type => 0x800, :nw_proto => 6})))
                 end
                  end
        def packet_in(datapath_id, message)
                         info "Message In Port: #{message.in_port}"
                          query_stats()
                         # Copy learning switch function
                         @fdb.learn message.macsa, message.in_port
                          port_no = @fdb.port_no_of(message.macda)
                              info "Port Number of learning switch #{port_no}"
                                                        if port_no
                                                                if (message.arp?)
                                                                            if (message.in_port == 2 || message.in_port == 3)
                                                                                        $path = decide_path()
                                                                                        $H1[message.in_port] = $path
                                                                    #info "Source port is #{message.in_port} and path chosen is #{$path}"
                                                                    info "Packet goes from #{message.in_port} to #{$path}"
                                                                                        flow_mod datapath_id, message, $path, message.arp_tpa
                                                                                        packet_out datapath_id, message, $path, message.arp_tpa
                                                                            else
                                                                                        flow_mod datapath_id, message, port_no, message.arp_tpa
                                                                                        packet_out datapath_id, message, port_no, message.arp_tpa
                                                                                end
														 elsif message.ipv4?
                                                                                if (message.in_port == 2 || message.in_port == 3)
                                                                                    if ($H1.key?(message.in_port))
                                                                                        #info "Source port is #{message.in_port} and path chosen is #{$H1[message.in_port]} "
                                                                                        info "Packet goes from #{message.in_port} to #{$path}"
                                                                                        flow_mod datapath_id, message, $H1[message.in_port], $H[$H1[message.in_port]]
                                                                                        packet_out datapath_id, message, $H1[message.in_port], $H[$H1[message.in_port]]
                                                                                        else
                                                                        $path = decide_path()
                                                                                        $H1[message.in_port] = $path
                                                                                        #info "Source port is #{message.in_port} and path chosen is #{$path}"
                                                                                        info "Packet goes from #{message.in_port} to #{$path}"
                                                                                        flow_mod datapath_id, message, $path, $H[$path]
                                                                                        packet_out datapath_id, message,$path, $H[$path]
                                                                                        end
                                                                                end
                                                                end
                                                        else
                                                                flood datapath_id, message
                                                        end
             info "Exited packet in"
        end
	def stats_reply (datapath_id, message)
                    puts "[flow stats_reply #{datapath_id}]---------------------------------"
                    byte_count = 0
                    packet_count = 0
                    flow_count = 0
                    throughput = 0
                    inst_throughput =0
                    total_flow_count = message.stats.length
                    if(total_flow_count != 0)
                      message.stats.each do | flow_msg |
                        # WARNING: This only works for the EXACT case of two actions. If we add more than two actions the flow monitoring
                        # will break.
                        flow_ip = flow_msg.match
                          puts "This is the message #{flow_ip.nw_src}"
                            flow_count = flow_count + 1
                            byte_count += flow_msg.byte_count
                           packet_count += flow_msg.packet_count
                     if flow_msg.duration_sec + flow_msg.duration_nsec/1000000000 != 0
                          throughput += flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000)
                          file = File.open("/tmp/flowstats.out", "a")
                          file.puts "#{flow_ip.nw_src} #{flow_count.to_s} #{byte_count} #{packet_count} #{throughput} Bps"
                          file.close
                     end
                  end
                end
    @prev_byte_count = byte_count
  end
                def decide_path()
        path = @one
        if @last == :one
                path = @two
                @last = :two
                info "Path two is being chosen"
        else
                @last = :one
                info "Path one is being chosen"
        end
        return path
        end
		def flow_removed datapath_id, message
		info "Flow is removed #{message.match.in_port}"
		if (message.match.in_port == 2 || message.match.in_port == 3)
		$H1.delete(message.match.in_port)
		$test = $H1[message.match.in_port]
		$H1.delete(message.match.in_port){ |e1| "#{e1} not found"}
		info "#{$test}"
		info "The port removed from hashmap is #{message.match.in_port}"
		end
		end
		def flow_mod datapath_id, message, port_no, ip
                actions = []
                if (message.ipv4?)
                   info "This is an IP packet #{ip}"
                   actions.push(SetIpDstAddr.new(ip.to_s))
                  send_flow_mod_add(datapath_id,
                                                                        :match => Match.new(
                                    :nw_src => message.ipv4_saddr,
                                    :nw_dst => message.ipv4_daddr,
                                    :in_port => message.in_port),
                                                                :actions => actions.push(ActionOutput.new( :port => port_no )),
                                                                :idle_timeout => 60
                  )
                  info " Actions #{actions}"
                 info "Sending flow mod out of Port #{port_no} with Dest Mac #{message.macda} Dest ip  #{message.ipv4_daddr} arp #{message.arp_tpa}"
                elsif message.arp?
                info "The ARP IP is #{ip}"
                send_flow_mod_add(datapath_id,
                                                                                        :match => Match.new(
                                            :nw_src => message.arp_spa,
                                            :nw_dst => message.arp_tpa,
                                            :in_port => message.in_port),
                                                                :actions => actions.push(ActionOutput.new( :port => port_no )),
                                                                :idle_timeout => 60
                  )
                                  info "Should not enter: Sending flow out of Port #{port_no} with Dest Mac #{message.macda} Dest ip #{message.ipv4_daddr} arp #{message.arp_tpa}"
                  end
               info "Modifying flow message #{message} "
        end
        def packet_out datapath_id, message, port_no, ip
                info "Sending Packet Out #{message} #{message.ipv4_daddr} arp? #{ip}"
                actions = []
                 if ((message.ipv4?))
                    actions.push(SetIpDstAddr.new(ip.to_s))
                end
                 send_packet_out(
                          datapath_id,
                           :packet_in => message,
                           :actions => actions.push(ActionOutput.new( :port => port_no ))
                 )
                 info "Sending packet out of Port #{port_no} with Dest Mac #{message.macda} Dest ip  #{message.ipv4_daddr} arp #{message.arp_tpa}"
                 info " Actions #{actions}"
                 puts port_no
        end

	

		def flood datapath_id, message
            info "Flooding #{message.arp_tpa} IP #{message.ipv4_daddr}"
            if message.arp?
              packet_out datapath_id, message, OFPP_FLOOD, message.arp_tpa
             end
           end
end
