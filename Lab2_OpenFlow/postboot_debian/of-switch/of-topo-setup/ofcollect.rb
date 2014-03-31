#!/usr/bin/env ruby
require 'rubygems'
require 'oml4r'
require 'file-tail'
APPNAME = "ofstats"
class MPThroughput < OML4R::MPBase
   name :ofthroughput
   param :pathtype, :type => :string
   param :numflows, :type => :int64
   param :numbytes, :type => :int64
   param :numpacket, :type => :int64
   param :throughput, :type => :int64
   param :units,      :type => :string
   param :avgperflow, :type => :int64
   param :units2,      :type => :string
end
class OFStatsWrapper
  def initialize(args)
     @addr = nil
     @if_num = ' '
     @trema_port = ' '
     @trema_path = ' '
     @verbose = true
     @numeric = ' '
     OML4R::init(args, :appName => "#{APPNAME}_wrapper", :domain => 'foo', :collect => 'file:-') {  |argParser|
       argParser.banner = "Reports OpenFlow stat measurements via OML\n\n"
       argParser.on("-f" , "--file_path ADDRESS", "Path where output is saved"){ |address| @addr = address }
       argParser.on("-i","--interface IFNUM","Interface number"){ |if_num| @if_num ="#{if_num.to_i()}" }
       argParser.on("-q", "--no-quiet ","Don't show of stats output on console"){ @verbose = false }
       argParser.on("-n", "--[no]-numeric ", "No attempt twill be made to look up symbolic names for host addresses"){ @numeric ='-n' }
    }
     unless @addr !=nil
      raise "You did not specify path of file (-p option)"
    end
end
class MyFile < File
  include File::Tail
end
def start()
                log = MyFile.new("#{@addr}")
                log.interval = @if_num
                log.backward(3)
                puts "#{@if_num}"
                log.tail { |line| print line
                processOutput(line)
                }
end
def processOutput(output)
  column = output.split(" ")
      puts "Each line process"
      # Inject the measurements into OML
      MPThroughput.inject("#{column[0]}", column[1], column[2], column[3], column[4], "#{column[5]}", column[6], "#{column[7]}" )
end
end
begin
  app = OFStatsWrapper.new(ARGV)
  app.start()
  rescue SystemExit
  rescue SignalException
     puts "OFWrapper stopped."
  rescue Exception => ex
  puts "Error - When executing the wrapper application!"
  puts "Error - Type: #{ex.class}"
  puts "Error - Message: #{ex}\n\n"
  # Uncomment the next line to get more info on errors
  # puts "Trace - #{ex.backtrace.join("\n\t")}"
end
OML4R::close()
# Local Variables:
# mode:ruby
# End:
# vim: ft=ruby:sw=2
