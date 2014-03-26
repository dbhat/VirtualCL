class Aggregator < Controller
    @@OTHER_PRIO_IN = 1
    @@OTHER_PRIO_OUT = 2
    @@UNKNOWN_PRIO = 5
    @@TUPLE_PRIO = 10

    @@TIMEOUT = 30 # Short 30 second rule timeout

    @@FakeMessage = Struct.new(:ipv4_saddr, :ipv4_daddr, :tcp_src_port, :tcp_dst_port)

    def start
        @left = nil
        @right = nil
        @inside = nil
        @flows = {}
        File.open('/tmp/portmap') do |f|
            f.each do |l|
                name, number = l.chomp.split(' ')
                case name
                when 'left'
                    @left = number.to_i
                when 'right'
                    @right = number.to_i
                when 'inside'
                    @inside = number.to_i
                else
                    $stderr.puts "Unrecognized port '#{name}'"
                    exit 1
                end
            end
        end
        if not @left or not @right or not @inside
            $stderr.puts "Missing port in /tmp/portmap, require left, right, inside"
            exit 1
        end
    end

    def switch_ready(datapath_id)
        # Just send non-TCP outbound traffic ... wherever
        send_flow_mod_add(datapath_id, :priority => @@OTHER_PRIO_OUT,
                          :match => Match.new(:dl_type => 0x0800,
                                              :in_port => @inside),
                          :actions => ActionOutput.new(@left))
        send_flow_mod_add(datapath_id, :priority => @@OTHER_PRIO_OUT,
                          :match => Match.new(:dl_type => 0x0806,
                                              :in_port => @inside),
                          :actions => ActionOutput.new(@right))
        # All incoming traffic goes to the @inside port
        send_flow_mod_add(datapath_id, :priority => @@OTHER_PRIO_IN,
                          :match => Match.new(:dl_type => 0x0800),
                          :actions => ActionOutput.new(@inside))
        send_flow_mod_add(datapath_id, :priority => @@OTHER_PRIO_IN,
                          :match => Match.new(:dl_type => 0x0806),
                          :actions => ActionOutput.new(@inside))
        # This matches both directions forward TCP traffic to controller
        send_flow_mod_add(datapath_id, :priority => @@UNKNOWN_PRIO,
                          :match => Match.new(:dl_type => 0x800,
                                              :nw_proto => 6),
                          :actions => ActionOutput.new(OFPP_CONTROLLER))
    end

    def message_tuple(message)
        order = :inout
        # This is just arbitrary tiebreaking, so use string reps
        if message.ipv4_daddr.to_s < message.ipv4_saddr.to_s or
                (message.ipv4_daddr.to_s == message.ipv4_saddr.to_s and
                 message.tcp_dst_port < message.tcp_src_port)
            order = :outin
        end
        if order == :inout
            "#{message.ipv4_saddr}:#{message.tcp_src_port}-#{message.ipv4_daddr}:#{message.tcp_dst_port}"
        else
            "#{message.ipv4_daddr}:#{message.tcp_dst_port}-#{message.ipv4_saddr}:#{message.tcp_src_port}"
        end
    end

    def packet_in(datapath_id, message)
        # Throw out anything we don't recognize
        return if not message.ipv4? or not message.tcp?

        # TCP flows are moved to follow incoming TCP packets.  This
        # means that for each incoming flow from the balanced links, we
        # install a rule on the incoming port and on @inside to pass the
        # flow without processing.  We put no rule on the opposite flow
        # balanced link, however, so that if the load balancer on the
        # other end "moves" a flow we will respond next time we see a
        # packet.

        flow = message_tuple(message)

        inport = message.in_port
        direction = inport == @inside ? :out : :in

        if direction == :in and @flows[flow]
            # This flow exists, so it must be on the other load balanced
            # link.  Delete it from the other load balanced link and the
            # @inside port.
            clear_flow(datapath_id, message,
                       message.in_port == @left ? @right : @left, flow)
        end

        # If this first packet is on @inside, then just pick an output
        # port; the returning packets will "choose" a side for us.
        # Otherwise assign this flow to @message.in_port.
        otherport = direction == :out ? (rand < 0.5 ? @left : @right) : @inside

        forward = {
            :priority => @@TUPLE_PRIO,
            :match => Match.new(:dl_type => 0x0800,
                                :nw_proto => 6,
                                :nw_src => message.ipv4_saddr,
                                :nw_dst => message.ipv4_daddr,
                                :tp_src => message.tcp_src_port,
                                :tp_dst => message.tcp_dst_port,
                                :in_port => inport),
            :actions => ActionOutput.new(otherport)
        }

        reverse = {
            :priority => @@TUPLE_PRIO,
            :match => Match.new(:dl_type => 0x0800,
                                :nw_proto => 6,
                                :nw_src => message.ipv4_daddr,
                                :nw_dst => message.ipv4_saddr,
                                :tp_src => message.tcp_dst_port,
                                :tp_dst => message.tcp_src_port,
                                :in_port => otherport),
            :actions => ActionOutput.new(inport)
        }

        # Always set the timeout on the path from @inside
        if direction == :out
            forward[:idle_timeout] = @@TIMEOUT
            reverse[:send_flow_rem] = false
        else
            forward[:send_flow_rem] = false
            reverse[:idle_timeout] = @@TIMEOUT
        end
            
        send_flow_mod_add(datapath_id, forward)
        send_flow_mod_add(datapath_id, reverse)

        if message.total_len > 63
          send_packet_out(datapath_id, :packet_in => message,
               :actions => ActionOutput.new(otherport))
        end
        
        @flows[flow] = direction == :in ? inport : otherport
    end

    def flow_removed(datapath_id, message)
        msg = @@FakeMessage.new(message.match.nw_dst,
                                message.match.nw_src,
                                message.match.tp_dst,
                                message.match.tp_src)
        flow = message_tuple(msg)
        otherport = @flows[flow]

        if not otherport
            $stderr.puts "Got a flow_removed on a flow that does not exist?"
            return
        end

        clear_flow(datapath_id, msg, otherport, flow)
    end

    def clear_flow(datapath_id, message, otherport, flow = message_tuple(msg))
        send_flow_mod_delete(datapath_id, :priority => @@TUPLE_PRIO,
                             :match => Match.new(:dl_type => 0x0800,
                                                 :nw_proto => 6,
                                                 :nw_src => message.ipv4_saddr,
                                                 :nw_dst => message.ipv4_daddr,
                                                 :tp_src => message.tcp_src_port,
                                                 :tp_dst => message.tcp_dst_port,
                                                 :in_port => otherport),
                             :actions => ActionOutput.new(@inside),
                             :send_flow_rem => false)
        send_flow_mod_delete(datapath_id, :priority => @@TUPLE_PRIO,
                             :match => Match.new(:dl_type => 0x0800,
                                                 :nw_proto => 6,
                                                 :nw_src => message.ipv4_daddr,
                                                 :nw_dst => message.ipv4_saddr,
                                                 :tp_src => message.tcp_dst_port,
                                                 :tp_dst => message.tcp_src_port,
                                                 :in_port => @inside),
                             :actions => ActionOutput.new(otherport),
                             :idle_timeout => @@TIMEOUT)
        @flows.delete flow
    end
end
