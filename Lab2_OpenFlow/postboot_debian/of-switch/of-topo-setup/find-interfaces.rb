#!/usr/bin/ruby

ifs = {}

File.open('/var/emulab/boot/ifmap') do |f|
    f.each do |l|
        iface, addr, rest = l.split(' ')
        ifs[addr] = iface
    end
end

ARGV.each do |iface|
    puts ifs[iface]
end
