class multicast < Controller
members =[]

  def start
    puts "Started"
  end


  def packet_in datapath_id, message
   if message.ip?
	  if message.in_port == 1
		File.open("hello.txt", "r") do |f|
			f.each_line do |line|
				if line[3] == '1'
					members.push(line[1])
				end
			end
		end
		flow_mod datapath_id, members, message
        packet_out datapath_id, members, message
	  end	

  end


  ##############################################################################
  private
  ##############################################################################


  def flow_mod datapath_id, members, message
    send_flow_mod_add(
      datapath_id,
      :match => ExactMatch.from( message ),
      :actions => output_actions( members ),
      :hard_timeout => 5
    )
  end


  def packet_out datapath_id, members, message
    send_packet_out(
      datapath_id,
      :packet_in => message,
      :actions => output_actions( members )
    )
  end


  def output_actions members
    members.collect do | each |
      ActionOutput.new( :port => each )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
