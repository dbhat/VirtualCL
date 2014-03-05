#
# Simple learning switch application in Ruby
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


require "fdb"


#
# A OpenFlow controller class that emulates a layer-2 switch.
#
class LearningSwitch < Controller
  add_timer_event :age_fdb, 600, :periodic


  def start
    puts "Start"
    @fdb = FDB.new
    @switches = {"GARack" => 0x06dc6c3be5666b00, "NWRack" => 0x6d66c3be5680000, "Internet2" => 0x6d60012e222636e, "SoX-SDX" => 0x13440b5031400, "StarLight" => 0x60eb69215a2f, "Sox-Rack" => 0x06d66c3be56cc500}
  end

  def switch_ready dpid
    # puts "Switch #{@switches.index(dpid)} (#{dpid.to_hex}) has signed in"
    puts "Switch #{@switches.key(dpid)} has signed in"
    # info " datapath_id: #{ dpid.to_hex }"
    # send_message dpid, FeaturesRequest.new
  end


  def packet_in datapath_id, message
    return if message.macda.reserved?
    
    puts "First new packet in from #{message.ipv4_saddr} on #{@switches.key(datapath_id)}"
    @fdb.learn message.macsa, message.in_port
    port_no = @fdb.port_no_of( message.macda )
    if port_no
      flow_mod datapath_id, message, port_no
      packet_out datapath_id, message, port_no
    else
      flood datapath_id, message
    end
  end


  def age_fdb
    @fdb.age
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
