#!/usr/bin/ruby1.9.1
require 'rubygems'
require 'oml4r'

class MPThroughput < OML4R::MPBase
   name :ofthroughput
   param :portnum, :type => :string
   param :numflows, :type => :uint64
   param :numbytes, :type => :uint64
   param :numpacket, :type => :uint64
   param :throughput, :type => :uint64
   param :units,	:type => :string
end
   

class OFStatsWrapper

  def initialize(args)
     @addr = nil
     @verbose = true
     @numeric = ''
     @follow = true
     leftover = OML4R::init(args, :appName => 'ofstats') do |argParser|
       argParser.banner = "Reports OpenFlow stat measurements via OML\n\n"
       argParser.on("-p" , "--file_path ADDRESS", "Path where output is saved"){ |address| @addr = address.to_s() }
       argParser.on("-f", "--follow ","Follow output of file"){ @follow = false }
       argParser.on("-q", "--no-quiet ","Don't show of stats output on console"){ @verbose = false }
       argParser.on("-n", "--[no]-numeric ", "No attempt twill be made to look up symbolic names for host addresses"){ @numeric ='-n' }
    end
    
end

def process_output(row)
  if not(parse= /(?<portnum>[a-z0-9]*)\s(?<numflows>\d*)\s(?<numbytes>\d*)\s(?<numpacket>\d*)\s(?<throughput>\d*)\s(?<units>[a-z]*)/.match(row)).nil?
  MPThroughput.inject(parse[:portnum], parse[:numflows], parse[:numbytes], parse[:numpacket], parse[:throughput], parse[:units])
  end
end
  
def ofstats()
   tailio=IO.popen("/usr/bin/tail #{@follow} #{@addr}")
   while true
    row = readline()
    puts row if @verbose
    process_output(row)
    end
end

def start()
    #return if not @pingio.nil? 
    # handle for OMF's exit command
    a = Thread.new do
      $stdin.each do |line|
    if /^exit/ =~ line
      Process.kill("INT",0)    
    end
      end
    end
    
    # Handle Ctrl+C and OMF's SIGTERM
    Signal.trap("INT", stop)
    Signal.trap("TERM", stop)
    
    begin
      ofstats
    rescue EOFError
    
    end
end

def stop()
   #return if @pingio.nil?
   # Kill the ping process, which will result in EOFError from ping()
   #Process.kill("INT", @pingio.pid)
end

end
begin
  $stderr.puts "INFO\tOFStats 2.11.0\n"
  app = OFStatsWrapper.new(ARGV)
  app.start()
  sleep 1
rescue Interrupt
rescue Exception => ex
   $stderr.puts "Error\t#{ex}\n"
end



# Local Variables:
# mode:ruby  
# End:
# vim: ft=ruby:sw=2