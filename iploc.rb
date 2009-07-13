#!/usr/bin/env ruby
##
## Copyright 2007 Matthew Lee Hinman
## matthew [dot] hinman [at] gmail [dot] com
##
## Query hostip.info to see where all the ip addresses in a pcap file
## originate from. Results are outputed into CSV format.
##
## Usage: ./iploc -r <pcap_file>
##
## Output format:
## <ip address>,<country>,<city and state>,<latitude>,<longitude>,<packet count>
##

require 'pcaplet'
include Pcap

## Hash containing all the addresses
$inaddrs = {}
$outaddrs = {}

class Address
  def initialize(ip,country,city,lat,long)
    @ip  = ip
    @country = country
    @city = city
    @lat = lat
    @long = long
    @count = 1
  end
  
  def inc
    @count = @count + 1
  end
  
  def to_s
    return "#{@ip.chomp},#{@country.chomp},#{@city.chomp},#{@lat.chomp},#{@long.chomp},#{@count}"
  end
end

def aggregate
  puts "Inbound Addresses:"
  $inaddrs.each { |k,v|
    puts v.to_s
    
  }
  puts "\nOutbound Addresses:"
  $outaddrs.each { |k,v|
    puts v.to_s
    
  }
end

trap "SIGINT", proc{
  aggregate()
  exit(0)
}

pcaplet = Pcaplet.new("-n")
STDERR.puts "Aggregating...CTRL-C to finish (if in live capture mode)."

pcaplet.each_packet { |pkt|
  if pkt.ip?
    ipaddr = pkt.src.to_s

    ## Short-circuit if we already have it in the database
    if $inaddrs.has_key?(ipaddr)
      $inaddrs[ipaddr].inc()
      next
    end

    fname = "/tmp/" + ipaddr + ".iptmp.tmp"
    `wget -q 'http://api.hostip.info/get_html.php?ip=#{ipaddr}&position=true' -O #{fname}` unless File.exist?(fname)

    f = File.open(fname,"r")
    
    ## Default values
    country = "Unknown"
    city = "Unknown"
    lat = ""
    long = ""

    f.each_line {
      |line|
      #puts line
      if line =~ /Country:\s([\s\S]+)$/i
        country = $1
      elsif line =~ /City:\s([\s\S]+)$/i
        city = $1
      elsif line =~ /Latitude:\s([\s\S]+)$/i
        lat = $1
      elsif line =~ /Longitude:\s([\s\S]+)$/i
        long = $1
      end
    }
    
    ## Remove commas from city
    city.gsub!(/,/,"")
    $inaddrs[ipaddr] = Address.new(ipaddr,country,city,lat,long)
    
    ##############################
    ## Now for outbound packets ##
    ##############################
    ipaddr = pkt.dst.to_s

    ## Short-circuit if we already have it in the database
    if $outaddrs.has_key?(ipaddr)
      $outaddrs[ipaddr].inc()
      next
    end

    fname = "/tmp/" + ipaddr + ".iptmp.tmp"
    `wget -q 'http://api.hostip.info/get_html.php?ip=#{ipaddr}&position=true' -O #{fname}` unless File.exist?(fname)

    f = File.open(fname,"r")
    
    ## Default values
    country = "Unknown"
    city = "Unknown"
    lat = ""
    long = ""

    f.each_line {
      |line|
      #puts line
      if line =~ /Country:\s([\s\S]+)$/i
        country = $1
      elsif line =~ /City:\s([\s\S]+)$/i
        city = $1
      elsif line =~ /Latitude:\s([\s\S]+)$/i
        lat = $1
      elsif line =~ /Longitude:\s([\s\S]+)$/i
        long = $1
      end
    }
    
    ## Remove commas from city
    city.gsub!(/,/,"")
    $outaddrs[ipaddr] = Address.new(ipaddr,country,city,lat,long)
  end
}

## If we're reading a pcap file, it'll get here when it's done
aggregate()

