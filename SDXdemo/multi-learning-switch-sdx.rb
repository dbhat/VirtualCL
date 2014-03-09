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


  def start
    puts "Start"
    @fdbs = Hash.new do | hash, datapath_id |
      hash[ datapath_id ] = FDB.new
    end

    @switches = {"SLEG-1655" => 0x0001749975e3c000, "NWIG-1750" => 0x6d66c3be5680000, "GTIG-1756" => 0x06dc6c3be5666b00, "SOXIG-1755" => 0x06db6c3be56cc500, "SOXIG-1756" => 0x06dc6c3be56cc500, "Internet2" => 0x6d60012e222636e, "SOXSDX" => 0x13440b5031400}
  end

  def switch_ready dpid
    puts "Switch #{@switches.key(dpid)} - #{dpid.to_s(16)} has signed in"
    # send_message dpid, FeaturesRequest.new
    # add_periodic_timer_event(:query_stats, 10)
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
    if port_no
      puts "hi"
      puts "#{@switches.key(datapath_id)}: #{message.macda} lives at #{port_no}"
      flow_mod datapath_id, message, port_no
      packet_out datapath_id, message, port_no
    else
      puts "#{@switches.key(datapath_id)}: flood for  #{message.macda}"
      flood datapath_id, message
    end
  end


  def age_fdbs
    @fdbs.each_value do | each |
      each.age
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def flow_mod datapath_id, message, port_no
    send_flow_mod_add(
      datapath_id,
      :match => ExactMatch.from( message ),
      :actions => ActionOutput.new( :port => port_no )
    )
  end


  def packet_out datapath_id, message, port_no
    send_packet_out(
      datapath_id,
      :packet_in => message,
      :actions => ActionOutput.new( :port => port_no )
    )
  end


  def flood datapath_id, message
    packet_out datapath_id, message, OFPP_FLOOD
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
