#
# Learning switch application that supports multiple switches
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#require Process

$LOAD_PATH << File.join( File.dirname( __FILE__ ), "../learning_switch/" )

class CircularList < Array
  def index
    @index ||=0
    @index.abs 
  end
  
  def current
    @index ||= 0
    get_at(@index)
  end
  
  def next(num=1)
    @index ||= 0
    @index += num
    get_at(@index)
  end
  
  def previous(num=1)
    @index ||= 0
    @index -= num
    get_at(@index)
  end
  
  private
  def get_at(index)
    if index >= 0
      at(index % self.size)
    else
      index = self.size + index
      get_at(index)
    end
  end
  
end

#
# A OpenFlow controller class that emulates multiple layer-2 switches.
#
class MultiLearningSwitch < Controller

  def start
    @stats_period = 1
    #add_timer_event :query_stats, @stats_period, :periodic
    #add_timer_event :switch_paths, 60, :periodic
    puts "Start"
    #@used_paths = CircularList.new (["I2", "ESNET", "ORNL", "I2-ESNET"])
    @used_paths = CircularList.new (["ESNET","I2","ORNL"])
    puts @used_paths.current
    @switches = {"SLSDX" => 0x000060eb69215a2f, "SOXSDX" => 0x00013440b5031400}

    @radars_nw = ["192.168.10.1", "192.168.10.2", "192.168.10.3", "192.168.10.4","192.168.10.5"]
    @radars_sl = ["192.168.10.101", "192.168.10.102", "192.168.10.103", "192.168.10.104"]
    @nowcastbox = ["192.168.10.10"]

    # Here we set the incoming ports for the SoX SDX switch. This will help with monitoring flows on this switch.
    @soxsdx_i2      = 26 
    @soxsdx_ornl    = 27
    @soxsdx_esnet   = 25
    @soxsdx_soxig   = 52
    @init           = 0
    # Here we set the incoming ports for the SL SDX switch.
    @slsdx_i2       = 52 
    @sl_ornl        = 4
    @sl_esnet       = 4
    @sl_nwig  	    = 1
    @best_path      = "esnet"
    @min_tput       = 1
    @max_tput       = 100000000000000000 
     @byte_count = {"i2" => 0, "esnet" => 0, "ornl" => 0}
   @packet_count = {"i2" => 0, "esnet" => 0, "ornl" => 0}
    @flow_count = {"i2" => 0, "esnet" => 0, "ornl" => 0}
    @throughput = {"i2" => 0, "esnet" => 0, "ornl" => 0}
    @inst_throughput = {"i2" => 0, "esnet" => 0, "ornl" => 0} 
    @prev_byte_count = {"i2" => 0, "esnet" => 0, "ornl" => 0}
end

  def switch_ready dpid
      #puts "DPID of switch : #{@switches.key(dpid)}"
     #Thread.new do
     # while 1 do
      # query_stats()
      # sleep(1)
      #end
     #end
    if @switches.key(dpid) == "SLSDX"
     puts "SLSDX switch"
     @slsdx = dpid
     # send_flow_mod_add(dpid, :match => Match.new(:in_port => @sl_nwig),
     #     			      :actions => ActionOutput.new(@slsdx_i2))
     # send_flow_mod_add(dpid, :match => Match.new(:in_port => @sl_ornl),
      #                                :actions => ActionOutput.new(@sl_nwig))
     # send_flow_mod_add(dpid, :match => Match.new(:in_port => @sl_esnet),
      #                                :actions => ActionOutput.new(@sl_nwig))
      #send_flow_mod_add(dpid, :match => Match.new(:in_port => @sl_i2),
       #                               :actions => ActionOutput.new(@sl_nwig))
    end
    if @switches.key(dpid) == "SOXSDX"
      puts "SOXSDX switch"
      @soxsdx = dpid
      #send_flow_mod_add(dpid, :match => Match.new(:in_port => @soxsdx_i2),
       #                              :actions => ActionOutput.new(@soxsdx_soxig))
     # send_flow_mod_add(dpid, :match => Match.new(:in_port => @soxsdx_esnet),
      #                               :actions => ActionOutput.new(@soxsdx_soxig))
      #send_flow_mod_add(dpid, :match => Match.new(:in_port => @soxsdx_ornl),
       #                               :actions => ActionOutput.new(@soxsdx_soxig))
      #send_flow_mod_add(dpid, :match => Match.new(:in_port => @soxsdx_soxig),
       #                              :actions => ActionOutput.new(@soxsdx_i2))
    end
      
  end
def query_stats
  if @slsdx != nil
      puts "SL Querying stats--------------------------------"
      send_message(@slsdx,
        FlowStatsRequest.new(:match => Match.new({:dl_type => 0x800})))
      send_message(@slsdx, PortStatsRequest.new)
    end
    #if @soxsdx != nil
     # puts "SOX Querying stats--------------------------------"
     # send_message(@soxsdx,
     #   FlowStatsRequest.new(:match => Match.new({:dl_type => 0x800})))
     #send_message(@soxsdx, PortStatsRequest.new) 
   #end
  end
  def packet_in datapath_id, message
    # Don't forward packets we don't care about
    #Thread.new do
    if message.lldp? or message.eth_type==50 or message.eth_type==0x86dd
      return
    end
   #pid=fork do
    puts "DPID is #{datapath_id.to_hex}"
     #print_message datapath_id, message
      puts "This is message is tcp or udp"
  #if @switches.key(datapath_id) == "SLSDX"
    query_stats()
#    Thread.new do
   #@mutex.synchronize {
    #    @statsReady.wait(@mutex)
    #}
   #end
    port_no, vlan_id = get_out_port datapath_id, message
    if port_no 
      puts "#{@switches.key(datapath_id)}: #{message.macda} lives at #{port_no}"
      flow_mod datapath_id, message, port_no, vlan_id
      packet_out datapath_id, message, port_no, vlan_id
    else
      puts "#{@switches.key(datapath_id)}: flood for  #{message.macda}"
      flood datapath_id, message, vlan_id
    end
   #end
 # Process.detach(pid)
    #Thread.new doi
   #end
end
  def switch_paths
    puts "SWITCHING PATHS to #{@best_path}"
    send_flow_mod_delete( @switches["SLSDX"])
    send_flow_mod_delete( @switches["SOXSDX"])
  end
    

  def stats_reply (dpid, message)
    puts "Received Stats #{@switches.key(dpid)}"
    if message.type == StatsReply::OFPST_FLOW
       process_flow_stats dpid, message
    end
    if message.type == StatsReply::OFPST_PORT
       process_port_stats dpid, message
    end
  end
  
  def process_port_stats (dpid, message)
    puts "NOT IMPLEMENTED"
  end

  def process_flow_stats (dpid, message)
    puts "[flow stats_reply #{@switches.key(dpid)}]---------------------------------"
    #Thread.new do
      #@max_tput = 0
    
    #byte_count = {"i2" => 0, "esnet" => 0, "ornl" => 0}
    #packet_count = {"i2" => 0, "esnet" => 0, "ornl" => 0}
    #flow_count = {"i2" => 0, "esnet" => 0, "ornl" => 0}
   #@throughput = {"i2" => 0, "esnet" => 0, "ornl" => 0}
    inst_throughput = {"i2" => 0, "esnet" => 0, "ornl" => 0}

    total_flow_count = message.stats.length
    if(total_flow_count != 0)
      message.stats.each do | flow_msg |
        # WARNING: This only works for the EXACT case of two actions. If we add more than two actions the flow monitoring
        # will break.
        if flow_msg.actions.length == 2 
          path = get_stats_path dpid, flow_msg.actions[1].port_number, flow_msg.actions[0].vlan_id
          puts "flow_count:PATH = #{path}"
          if path != "NOPATH"
	    @flow_count[path] = @flow_count[path] + 1
	    @byte_count[path] += flow_msg.byte_count
	    @packet_count[path] += flow_msg.packet_count
            if flow_msg.duration_sec + flow_msg.duration_nsec/1000000000 != 0
              @throughput[path] += flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000)
              @inst_throughput[path] = flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000) 
           end
          end
        end
       end  
           if not defined? @inst_throughput
              @inst_throughput = {"i2" => 0, "esnet" => 0, "ornl" => 0}
           end
    #if not defined? @prev_byte_count
      ['esnet', 'i2','ornl'].each do | path |
              #@inst_throughput[path] =  (@throughput[path] - @inst_throughput[path])/@stats_period
        #@inst_throughput[path] = (@throughput[path] - @prev_byte_count[path])/@stats_period
             info "#{path} #{@throughput[path]}-#{@inst_throughput[path]} Bps"
	    file = File.open("/tmp/flowstats.out", "a")
            file.puts "#{path} #{dpid} #{@flow_count[path].to_s} #{@byte_count[path]} #{@packet_count[path]} #{@throughput[path]} Bps #{@inst_throughput[path]} Bps"
	    file.close
          
      end
   # @mutex.synchronize {
    #  @statsReady.signal
    #} 
    #end
    @prev_byte_count = @throughput
    puts "Stats Reply #{@min_tput}"
   # @mutex.synchronize {
    #@statsReady.signal 
   # }
  #end
end
end

  ##############################################################################
  private
  ##############################################################################

  # This should be a function that determines what path a packet should take 
  # depending its source and dest IP address.
  #
  # def get_path hostip
  # if (radar[0]? hostip || radar[1]? hostip) and nowcast? dstip
  #   send out ESNET  
  # elsif (radar[0]? srcip || radar[1]? srcip) and nowcast? dstip
  #   send out I2
  # end

  def get_path hostip, datapath_id
    #Thread.new do
  # if @switches.key(datapath_id) == "SLSDX"
   #   puts "SWITCHID:SLSDX"
    # @mutex.synchronize{
     #  @statsReady.wait(@mutex)
   # }
    #end
    @best_path = decide_path(datapath_id)
    puts "USING PATH #{@best_path}"
    case @best_path
    when "I2"  # All traffic goes via I2
      if @switches.key(datapath_id) == "SLSDX"
        return "I2"
      elsif @switches.key(datapath_id) == "SOXSDX"
        return  "I2"
      end
    when "ORNL" # All traffic via ORNL
      if @switches.key(datapath_id) == "SLSDX"
        return "ORNL"
      elsif @switches.key(datapath_id) == "SOXSDX"
        return  "ORNL"
      end
    when "ESNET" # All traffic via ORNL
      if @switches.key(datapath_id) == "SLSDX"
        puts "Entered here1"
        return "ESNET"
      elsif @switches.key(datapath_id) == "SOXSDX"
         puts "Entered here2"
        return  "ESNET"
      end
    when "I2-ESNET" # Radars 1 and 2 via ESNET, radars 3 and 4 via I2
      if @switches.key(datapath_id) == "SLSDX"
          if @radars_nw[0] == hostip.to_s || @radars_nw[1] == hostip.to_s || @radars_nw[4] == hostip.to_s
            return "ESNET"
          elsif @radars_nw[2] ==  hostip.to_s || @radars_nw[3] == hostip.to_s
            return "I2"
          end
      elsif @switches.key(datapath_id) == "SOXSDX"
          # puts "#{@radars_sl[0]}, #{hostip}"
          if @radars_nw[0] == hostip.to_s || @radars_nw[1] == hostip.to_s || @radars_nw[4] == hostip.to_s
            # puts "get_path ESNET"
            return "ESNET"
          elsif @radars_nw[2] == hostip.to_s || @radars_nw[3] == hostip.to_s
            return "I2"
          end
      end
       when 1000 # To SOXSDL via ESNET, back via I2
      if @switches.key(datapath_id) == "SLSDX"
        return "ESNET"
      elsif @switches.key(datapath_id) == "SOXSDX"
        return  "I2"
      end
    else
      puts "WARNING: Case not defined!!"
    #end 
  end
end
  def get_out_port datapath_id, message
    srcip = get_src_ip message
    dstip = get_dst_ip message
    puts "Inside get out port"
    if srcip and dstip
      #Thread.new do
      #@mutex.synchronize{
       #   @statsReady.wait(@mutex)
      #}
      if radar? srcip and nowcast? dstip
        puts "From Radar to nowcast"
        puts @switches.key(datapath_id)
        if @switches.key(datapath_id) == "SLSDX"
           sdx_path = get_path srcip, datapath_id
	   # puts "SLSDX path #{sdx_path}"
           if sdx_path == "I2"
             # puts "52, 1709"
             return 52, 1709
           elsif sdx_path == "ORNL"
             # puts "4, 1650"
             return 4, 1650
           else
             # puts "4, 1651"
             return 4, 1651
           end
        end
        if @switches.key(datapath_id) == "SOXSDX"
           # puts "52, 1755"
           return 52, 1755
        end
      end
      if nowcast? srcip and radar? dstip
        puts "#{@switches.key(datapath_id)}:From nowcast to radar"
        puts dstip
        if @switches.key(datapath_id) == "SLSDX"
          if @radars_nw.include? dstip.to_s
           puts "host at NW"
           return 1, 1750
          elsif @radars_sl.include? dstip.to_s
           puts "host at SL"
           return 50, 1655
          end
           # puts "50, 1655"
        end
        if @switches.key(datapath_id) == "SOXSDX"
           sdx_path = get_path dstip, datapath_id
	   # puts "SOXSDX path #{sdx_path}"
           if sdx_path == "I2"
             # puts "26, untagged "
             return 26, 1649
           elsif sdx_path == "ORNL"
             # puts "27, 1650"
             return 27, 1650
             #return 27
             # XXX ALL REVERSE TRAFFIC THROUGH I2 SINCE THE OTHERS ARE NOT WORKING
             # return 26
           else
             # puts "25, 1651"
             return 25, 1651
             # XXX ALL REVERSE TRAFFIC THROUGH I2 SINCE THE OTHERS ARE NOT WORKING
             #return 25
             #return 26
           end 
        end
      end
      #end
    end
end

  def get_vlan_id message, datapath_id, port_no
    if message.vlan_vid == 1655
      return 1750
    else
      return 1655
    end
  end

  def make_vlan_action message, vlan_id
    actions = []
    if vlan_id
      actions.push(ActionSetVlanVid.new(vlan_id))
    else
      if message.vtag?
         actions.push(StripVlanHeader.new)
      end
    end
    return actions
  end

  def flow_mod datapath_id, message, port_no, vlan_id
    actions = make_vlan_action message, vlan_id
    send_flow_mod_add(
      datapath_id,
      :match => ExactMatch.from( message ),
      :actions => actions.push(ActionOutput.new( :port => port_no )),
      :idle_timeout => 10
    )
  end


  def packet_out datapath_id, message, port_no, vlan_id
    actions = make_vlan_action message, vlan_id
    #puts "Packet OUT"
    #puts ExactMatch.from (message)
    send_packet_out(
      datapath_id,
      :packet_in => message,
      :actions => actions.push(ActionOutput.new( :port => port_no ))
    )
    puts port_no  
end

  def flood datapath_id, message, vlan_id
    packet_out datapath_id, message, OFPP_FLOOD, vlan_id
  end

  def get_src_ip message
    ipsrc = ""
    if message.arp?
      ipsrc = message.arp_spa
    else
      if message.ipv4?
        ipsrc = message.ipv4_saddr
      end
    end
  end

  def get_dst_ip message
    ipsrc = ""
    if message.arp?
      ipsrc = message.arp_tpa
    else
      if message.ipv4?
        ipsrc = message.ipv4_daddr
      end
    end
  end
  
  def radar? ipaddr
    if @radars_nw.include? ipaddr.to_s or @radars_sl.include? ipaddr.to_s 
      return true
    end
    return false
  end

  def nowcast? ipaddr
    if @nowcastbox.include? ipaddr.to_s
      return true
    end
    return false
  end
  
  def print_message datapath_id, message
    str = "#{@switches.key(datapath_id)}:#{message.in_port} "
    str+="macsrc=#{message.macsa}, macaddr=#{message.macda},"
    if message.vtag?
      str+="vlanid=#{message.vlan_vid}, vlanpcp=#{message.vlan_prio},"
    end
    if message.arp?
      str+="arpsrc=#{message.arp_spa}, arpdst=#{message.arp_tpa},"
    end
    if message.ipv4?
      str+="ipsrc=#{message.ipv4_saddr}, ipdst=#{message.ipv4_daddr},"
    end
    if message.tcp?
      str+="tcpsp=#{message.tcp_src_port}, tcpdp=#{message.tcp_dst_port},"
    end
    if message.udp?
      str+="tcpsp=#{message.udp_src_port}, tcpdp=#{message.udp_dst_port},"
    end
    puts str
  end
      
  def get_stats_path dpid, port_no, vlan_id
     if @switches.key(dpid) == "SLSDX"
        if vlan_id == 1709 
           return 'i2'
        end
        if vlan_id == 1650
           return 'ornl'
        end
        if vlan_id == 1651
           return 'esnet'
        end
     end
      if @switches.key(dpid)  == "SOXSDX"
        # if vlan_id == 1750
        #   return 'i2'
        #end
        #if vlan_id == 1650
         #  return 'ornl'
        #end
        #if vlan_id == 1651
         #  return 'esnet'
        #end
        puts "SOXPORT #{port_no}, VLAN: #{vlan_id}"
      end 
     return "NOPATH"
  end
 def decide_path datapath_id
   #Thread.new do
    #if @switches.key(datapath_id) == "SLSDX"
    # puts "EnteredThreadWait"
    #@mutex.synchronize {
     # @statsReady.wait(@mutex)
    #}
   #end
    # ***user change code from here**************
    # ***Question: try change the code to make path decision based on***
    # ***Average per-flow throughput***
    # ***Note: you also need to change `stats_reply` to calculate average throughput***
    puts "Tryingtodecidepath"
    # we got the flow/packet/byte info from stats_reply handler
     @min_tput=@throughput['esnet']
     @path2="ESNET"
     ['esnet','i2', 'ornl'].each do | path |
            puts "Minimum Throughput #{@min_tput}"
            if @throughput[path] < @min_tput
                 puts "Entered here"
                 #min_tput1 = @throughput[path]
                 @min_tput = @throughput[path]
                 @path2 = path.upcase
                 puts "DecidePATH #{@best_path}"
            elsif @throughput[path] > @max_tput
                 @max_tput = @throughput[path]
           end
     end
    # Choose path based on the number of bytes sent
    return @path2
  #end
 #end
end

end

### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
## End:
