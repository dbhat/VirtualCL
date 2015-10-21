class MultiCast < Controller
$H = Hash[2 => "02:aa:d2:80:69:77", 3 => "02:d0:3c:1c:da:f8"]
$H1 = Hash[]
  def start
    puts "Started"
  end
def switch_ready(datapath_id)
        info "Switch is Ready! Switch id: #{datapath_id}"
        end
  def packet_in datapath_id, message
          if message.in_port == 4
                File.open("hello1.txt", "r") do |f|
                        f.each_line do |line|
                                if line[3] == '1'
                                        $H1[line[1].to_i] = $H[line[1].to_i]
                                        puts "#{$H1}"
                                end
                        end
                end
                flow_mod datapath_id, $H1, message
        packet_out datapath_id, $H1, message
          end
         if (message.in_port) == 2 || (message.in_port == 3)
         flow_mod datapath_id, 4, message
         packet_out datapath_id, 4, message
         end
  end
  ##############################################################################
  private
  ##############################################################################
  def flow_mod datapath_id, members, message
   puts members
   send_flow_mod_add(
      datapath_id,
      :match => ExactMatch.from( message ),
      :actions => output_actions( members ),
      :hard_timeout => 5
    )
  end
  def packet_out datapath_id, members, message
    puts members
    send_packet_out(
      datapath_id,
      :packet_in => message,
      :actions => output_actions( members )
    )
  end
  def output_actions members
   puts members
      if members.is_a?(Hash)
        members.collect do | key, value|
        puts "Port #{key} MAC address #{value}\n"
        ActionOutput.new( :port => key )
            end
      else
        ActionOutput.new(:port =>members)
      end
 end
end
### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
