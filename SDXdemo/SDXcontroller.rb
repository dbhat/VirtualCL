# This is the controller for the two SDX switches (SL and SOX) 


# Switches that are managed by this controller:
# SLSDX			00:00:60:eb:69:21:5a:2f		Load-balance    143.215.218.24:443
# SOXSDX		00:01:34:40:b5:03:14:00		Load-balance	143.215.218.24:443


class Dumper < Controller
  #add_timer_event :change_flows, 30, :periodic

  def start
	puts "Start"
        
        # Here we assign names to the dpids to make them more human readable
	@switches = {"SLSDX" => 0x000060eb69215a2f, "SOXSDX" => 0x00013440b5031400}

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

  end

  def switch_ready(dpid)
    	puts "Switch #{@switches.key(dpid)} has signed in"
   	send_message dpid, FeaturesRequest.new
   	# add_periodic_timer_event(:query_stats, 10)
  end

  def query_stats()
     puts "Querying stats"
     send_message(@switch1,
		FlowStatsRequest.new())
		    #:match => Match.new({dl_type => 0x800, nw_proto => 6}))
                    #)
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

  def packet_in (dpid, message)
    #return if @switches.key(dpid).nil? or @ports[dpid].nil?
    puts "Packet entered"
  end

  def flow_mod dpid, message, port_no
    send_flow_mod_add(
	dpid,
	:match => Match.from( message ),
	:actions => ActionOutput.new( :port => port_no),
	:idle_timeout => 2
    )
  end

  def packet_out dpid, message, port_no
    send_packet_out(
	dpid,
	:packet_in => message,
	:actions => ActionOutput.new( :port => port_no)
	)
  end
end

