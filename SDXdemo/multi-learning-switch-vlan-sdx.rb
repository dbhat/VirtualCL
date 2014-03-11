#
# Learning switch application that supports multiple switches
#
# Copyright (C) 2008-2013 NEC Corporation
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


$LOAD_PATH << File.join( File.dirname( __FILE__ ), "../learning_switch/" )

require "fdb"

#
# A OpenFlow controller class that emulates multiple layer-2 switches.
#
class MultiLearningSwitch < Controller
  add_timer_event :age_fdbs, 5, :periodic
  add_timer_event :query_stats, 10, :periodic


  def start
    puts "Start"
    @fdbs = Hash.new do | hash, datapath_id |
      hash[ datapath_id ] = FDB.new
    end

    @switches = {"SLSDX" => 0x000060eb69215a2f, "SOXSDX" => 0x00013440b5031400}

    @radars_nw = ["192.168.10.1", "192.168.10.2", "192.168.10.3", "192.168.10.4"]
    @radars_sl = ["192.168.10.101", "192.168.10.102", "192.168.10.103", "192.168.10.104"]
    @nowcastbox = ["192.168.10.10"]

    @path = "ESNET"  # Options are I2, ORNL, or ESNET are the other two options

    # Here we set the incoming ports for the SoX SDX switch. This will help with monitoring flows on this switch.
    @soxsdx_i2      = 26 
    @soxsdx_ornl    = 27
    @soxsdx_esnet   = 25

    # Here we set the incoming ports for the SL SDX switch.
    @slsdx_i2       = 52 
    @sl_ornl        = 4
    @sl_esnet       = 4
  end

  def switch_ready dpid
    puts "Switch #{@switches.key(dpid)} - #{dpid.to_s(16)} has signed in"
    # send_message dpid, FeaturesRequest.new
    if @switches.key(dpid) == "SLSDX"
      puts "SLSDX switch"
      @slsdx = dpid
    end
  end

  def packet_in datapath_id, message
    # Don't forward packets we don't care about
    if message.lldp? or message.eth_type==50 or message.eth_type==0x86dd
      return
    end
    fdb = @fdbs[ datapath_id ]
    port_no = fdb.port_no_of( message.macsa )
    if !port_no
      puts "#{@switches.key(datapath_id)}: Learned #{message.macsa} at #{message.in_port}"
    end
    fdb.learn message.macsa, message.in_port
    port_no = fdb.port_no_of( message.macda )
    vlan_id = get_vlan_id  message, datapath_id, port_no  # MZ: do we really need that line? vlan_id gets overwritten in the next line!
    port_no, vlan_id = get_out_port datapath_id, message
    if port_no
      puts "#{@switches.key(datapath_id)}: #{message.macda} lives at #{port_no}"
      flow_mod datapath_id, message, port_no, vlan_id
      packet_out datapath_id, message, port_no, vlan_id
    else
      puts "#{@switches.key(datapath_id)}: flood for  #{message.macda}"
      flood datapath_id, message, vlan_id
    end
  end

  def age_fdbs
    @fdbs.each_value do | each |
      each.age
    end
  end

  def query_stats
    if @slsdx != nil
      puts "Querying stats--------------------------------"
      send_message(@slsdx,
        FlowStatsRequest.new(:match => Match.new({:dl_type => 0x800})))
    end
  end

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
      message.stats.each do | flow_msg |
        # WARNING: This only works for the EXACT case of two actions. If we add more than two actions the flow monitoring
        # will break.
        if(flow_msg.actions.length == 2 && (flow_msg.actions[1].port_number == @slsdx_i2 ||
                                            flow_msg.actions[1].port_number == @sl_ornl || 
                                            flow_msg.actions[1].port_number == @sl_esnet)) 
          left_returned = 1
	  left_flow_count += 1
	  left_byte_count += flow_msg.byte_count
	  left_packet_count += flow_msg.packet_count
	  if flow_msg.duration_sec + flow_msg.duration_nsec/1000000000 != 0
            info "OFPort#{flow_msg.actions[1].port_number.to_s} VLan_ID#{flow_msg.actions[0].vlan_id} #{(flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000))} Bps"
	    # file = File.open("/tmp/flowstats.out", "a")
            # file.puts "OFPort#{flow_msg.actions[0].port_number.to_s} #{left_flow_count.to_s} #{left_byte_count} #{left_packet_count} #{(flow_msg.byte_count/(flow_msg.duration_sec + flow_msg.duration_nsec/1000000000))} Bps"
	    # file.close
          end
        end
      end
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
    a = 10
    case a
    when 1  # All traffic goes via I2
      if @switches.key(datapath_id) == "SLSDX"
        return "I2"
      elsif @switches.key(datapath_id) == "SOXSDX"
        return  "I2"
      end

    when 2 # All traffic via ORNL
      if @switches.key(datapath_id) == "SLSDX"
        return "ORNL"
      elsif @switches.key(datapath_id) == "SOXSDX"
        return  "ORNL"
      end

    when 3 # All traffic via ORNL
      if @switches.key(datapath_id) == "SLSDX"
        return "ESNET"
      elsif @switches.key(datapath_id) == "SOXSDX"
        return  "ESNET"
      end

    when 10 # Radars 1 and 2 via ESNET, radars 3 and 4 via I2
      if @switches.key(datapath_id) == "SLSDX"
          if @radars_sl[0] == hostip.to_s || @radars_sl[1] == hostip.to_s
            return "ESNET"
          elsif @radars_sl[2] ==  hostip.to_s || @radars_sl[3] == hostip.to_s
            return "I2"
          end
      elsif @switches.key(datapath_id) == "SOXSDX"
          # puts "#{@radars_sl[0]}, #{hostip}"
          if @radars_sl[0] == hostip.to_s || @radars_sl[1] == hostip.to_s
            # puts "get_path ESNET"
            return "ESNET"
          elsif @radars_sl[2] == hostip.to_s || @radars_sl[3] == hostip.to_s
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
    end
  end

  def get_out_port datapath_id, message
    srcip = get_src_ip message
    dstip = get_dst_ip message 
    if srcip and dstip
      if radar? srcip and nowcast? dstip
        # puts "From Radar to nowcast"
        # puts @switches.key(datapath_id)
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
        # puts "From nowcast to radar"
        # puts @switches.key(datapath_id)
        if @switches.key(datapath_id) == "SLSDX"
           # puts "50, 1655"
           return 50, 1655
        end
        if @switches.key(datapath_id) == "SOXSDX"
           sdx_path = get_path dstip, datapath_id
	   # puts "SOXSDX path #{sdx_path}"
           if sdx_path == "I2"
             # puts "26, untagged "
             return 26
           elsif sdx_path == "ORNL"
             # puts "27, 1650"
             return 27, 1650
           else
             # puts "25, 1651"
             return 25, 1651
           end 
        end
      end
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
      :actions => actions.push(ActionOutput.new( :port => port_no ))
    )
  end


  def packet_out datapath_id, message, port_no, vlan_id
    actions = make_vlan_action message, vlan_id
    send_packet_out(
      datapath_id,
      :packet_in => message,
      :actions => actions.push(ActionOutput.new( :port => port_no ))
    )
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
end

### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
