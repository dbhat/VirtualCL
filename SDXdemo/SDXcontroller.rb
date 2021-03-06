# This is the controller for the two SDX switches (SL and SOX) 


# Switches that are managed by this controller:
# SLSDX			00:00:60:eb:69:21:5a:2f		Load-balance    143.215.218.24:443
# SOXSDX		00:01:34:40:b5:03:14:00		Load-balance	143.215.218.24:443


class Dumper < Controller
  # add_timer_event :change_flows, 30, :periodic

  def start
	puts "Start"
        
        # Here we assign names to the dpids to make them more human readable
	@switches = {"SLSDX" => 0x000060eb69215a2f, "SOXSDX" => 0x00013440b5031400}
	# @switches = {"SLSDX" => 0x000060eb69215a2f, "SOXSDX" => 0x00013440b5031400, "SLEG-1655" => 0xaffe, "NWIG-1750" => 0x6d66c3be5680000, "GTIG-1756" => 0x06dc6c3be5686b00, "SOXIG-1755" => 0x06db6c3be56cc500, "SOXIG-1756" => 0x06dc6c3be56cc500}

    	# Here we set the incoming ports for the SoX SDX switch. This will help with monitoring flows on this switch.
    	@soxsdx_i2      = 26 
    	@soxsdx_ornl    = 27
    	@soxsdx_esnet   = 25
	@sox_gtig1756   = 64
	@sox_soxig1755  = 52
	@sox_soxig1756  = 52

        # Here we set the incoming ports for the SL SDX switch.
    	@slsdx_i2       = 52 
    	@sl_ornl        = 4
    	@sl_esnet       = 4
	@sl_sleg1655    = 50
        @sl_nwig1750    = 1


        # Source IP addresses of the radars
        @iprad1         = "192.168.10.1"
        @iprad2         = "192.168.10.2"
        @iprad3         = "192.168.10.3"
        @iprad4         = "192.168.10.4"

  end

  def switch_ready(dpid)
    	puts "Switch #{@switches.key(dpid)} has signed in"
        if @switches.key(dpid) == "SLSDX"
          puts "SLSDX switch"
          add_timer_event :query_stats, 10, :periodic
          @slsdx = dpid
        elsif @switches.key(dpid) == "SOXSDX"
          puts "SOXSDX switch"
          # add_timer_event :query_stats, 10, :periodic
          @soxsdx = dpid
        end
   	# send_message dpid, FeaturesRequest.new
  end

  def query_stats()
     puts "Querying stats"
     send_message(@slsdx,
		  FlowStatsRequest.new(
		    :match => Match.new({:dl_type => 0x800}))
                 )
  end

  def switch_disconnected(dpid)
	info "Switch #{dpid.to_hex} Disconnected"
  end

  def features_reply (dpid, message)
	@ports[dpid] = Hash.new
	message.ports.each do |p|
	puts "#{@switches.key(dpid)} : #{p.name} = #{p.number}"
	@ports[dpid][p.name] = p.number
	end
  end

  def stats_reply (dpid, message)
	puts "[stats_reply]---------------------------------"
      	message.stats.each do | flow_msg |
      		if(flow_msg.actions[0].port_number == @sl_nwig1750)
                        p "Port 1====================================="
                        p flow_msg.match.to_s
			p flow_msg.actions.to_s
		end
      		if(flow_msg.actions[0].port_number == @sl_sleg1655)
                        p "Port 50====================================="
                        p flow_msg.match.to_s
			p flow_msg.actions.to_s
		end
	end
  end

=begin
  def stats_reply (dpid, message)
	puts "[stats_reply]---------------------------------"
    	left_returned = 0
    	right_returned = 0
    	left_byte_count = 0
    	left_packet_count = 0
    	left_flow_count = 0
    	right_byte_count = 0
    	right_packet_count = 0
    	right_flow_count = 0
        flow_count = message.stats.length

    	if(flow_count != 0)
      		info "flow_count != 0"
      		if(flow_msg.actions[0].port_number == @slsdx_i2)
			left_returned = 1
			left_flow_count += 1
			left_byte_count += flow_msg.byte_count
			left_packet_count += flow_msg.packet_count
			if flow_msg.duration_sec + flow_msg.duration_nsec/1000000000 != 0
                        	# WARNING: Division by 0 possible. Needs to be fixed!!!!
          			info "OFPort#{flow_msg.actions[0].port_number.to_s} #{(flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000))} Bps"
				# file = File.open("/tmp/flowstats.out", "a")
          			# file.puts "OFPort#{flow_msg.actions[0].port_number.to_s} #{left_flow_count.to_s} #{left_byte_count} #{left_packet_count} #{(flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000))} Bps"
				# file.close
			end
		end
                end
        end
  end
=end

  def packet_in (dpid, message)
    #return if @switches.key(dpid).nil? or @ports[dpid].nil?
    # puts "First new packet in from #{message.ipv4_saddr} on #{@switches.key(dpid)}"
    if @switches.key(dpid) == "SLSDX"
      # puts "SLSDX: 1. First new packet in from #{message.ipv4_saddr} on #{@switches.key(dpid)}"
      if message.ipv4_saddr.to_s == "192.168.10.1"
        if message.ipv4_daddr.to_s == "192.168.10.101"
          puts "SLSDX: 2. First new packet to #{message.ipv4_daddr} on #{@switches.key(dpid)} should be 192.168.10.101"
          puts "Vlan ID: #{message.vlan_vid} in_port: #{message.in_port}"
          flow_mod dpid, message, @sl_sleg1655, 1655
          packet_out dpid, message, @sl_sleg1655, 1655
        else
          puts "SLSDX: 2. First new packet in from #{message.ipv4_saddr} on #{@switches.key(dpid)} should be 192.168.10.1"
          puts "Vlan ID: #{message.vlan_vid}"
          flow_mod dpid, message, @sox_soxig1755, 1750 
          packet_out dpid, message, @sox_soxig1755, 1750
        end
      end 
      if message.ipv4_saddr.to_s == "192.168.10.2"
        puts "SLSDX: 2. First new packet in from #{message.ipv4_saddr} on #{@switches.key(dpid)} should be 192.168.10.2"
      end 
      if message.ipv4_saddr.to_s == "192.168.10.3"
        puts "SLSDX: 2. First new packet in from #{message.ipv4_saddr} on #{@switches.key(dpid)} should be 192.168.10.3"
      end 
      if message.ipv4_saddr.to_s == "192.168.10.4"
        puts "SLSDX: 2. First new packet in from #{message.ipv4_saddr} on #{@switches.key(dpid)} should be 192.168.10.4"
      end 
     
      if message.ipv4_saddr.to_s == "192.168.10.101"
        puts "SLSDX: 2. First new packet to #{message.ipv4_daddr} on #{@switches.key(dpid)} should be 192.168.10.1"
        if message.ipv4_daddr.to_s == "192.168.10.1"
          puts "Vlan ID: #{message.vlan_vid} in_port: #{message.in_port}"
          flow_mod dpid, message, @sl_nwig1750, 1750 
          packet_out dpid, message, @sl_nwig1750, 1750
        else
          puts "SLSDX: 2. First new packet in from #{message.ipv4_saddr} on #{@switches.key(dpid)} should be 192.168.10.1"
          puts "Vlan ID: #{message.vlan_vid}"
          flow_mod dpid, message, @sox_soxig1755, 1755
          packet_out dpid, message, @sox_soxig1755, 1755
        end
      end 
     
    end
    if @switches.key(dpid) == "SOXSDX"
      puts "SOXSDX: 1. First new packet in from #{message.ipv4_daddr} on #{@switches.key(dpid)}"

      # This block is for frames coming from 192.168.10.1 and are destined for radars 1 through 4
      if message.ipv4_daddr.to_s == "192.168.10.1"
        puts "SOXSDX: 2. First new packet out to #{message.ipv4_daddr} on #{@switches.key(dpid)} should be 192.168.10.1"
      elsif message.ipv4_daddr.to_s == "192.168.10.2"
        puts "SOXSDX: 2. First new packet out to #{message.ipv4_daddr} on #{@switches.key(dpid)} should be 192.168.10.2"
      elsif message.ipv4_daddr.to_s == "192.168.10.3"
        puts "SOXSDX: 2. First new packet out to #{message.ipv4_daddr} on #{@switches.key(dpid)} should be 192.168.10.3"
      elsif message.ipv4_daddr.to_s == "192.168.10.4"
        puts "SOXSDX: 2. First new packet out to #{message.ipv4_daddr} on #{@switches.key(dpid)} should be 192.168.10.4"
      # This block is for segmenst coming from 10.10.10.10 and are destined for 10.10.10.11
      elsif message.ipv4_saddr.to_s == "10.10.10.10"
        puts "SOXSDX: 2. First new packet out to #{message.ipv4_daddr} on #{@switches.key(dpid)} should be 10.10.10.10"
        puts "Vlan ID: #{message.vlan_vid} in_port: #{message.in_port}, out_port #{@sox_gtig1756.to_i}"
        flow_mod dpid, message, @sox_gtig1756.to_i
        packet_out dpid, message, @sox_gtig1756.to_i
      end
    end
  end

  def flow_mod dpid, message, port_no, vlan_id
    send_flow_mod_add(
	dpid,
	:match => Match.from( message ),
	# :actions => ActionOutput.new( :port => port_no),
	# :actions => [ActionOutput.new( :port => port_no), ActionSetVlanVid.new(1655)],
	:actions => [ActionOutput.new(port_no), ActionSetVlanVid.new(vlan_id)],
	:idle_timeout => 2
    )
    # ActionSetVlanVid.new( vlan_id )
  end

  def packet_out dpid, message, port_no, vlan_id
    send_packet_out(
	dpid,
	:packet_in => message,
	# :actions => ActionOutput.new( :port => port_no),
	:actions => [ActionOutput.new(port_no), ActionSetVlanVid.new(vlan_id)],
	)
  end
end

