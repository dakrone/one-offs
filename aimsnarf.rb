#!/usr/bin/env ruby
##
## Written by: Matthew Lee Hinman
## matthew [dot] hinman [at] gmail [dot] com
## http://thnetos.wordpress.com
## Grabs AIM messages out of a pcap live stream or file
##
## Usage: ./aimsnarf -i <dev> or ./aimsnarf -r <pcap_file>
##

require 'pcaplet'
include Pcap

## This is kept here so that printing the raw packet gives tcpdump-like
## time stamps
#class Time
#  # tcpdump style format
#  def to_s
#    sprintf "%0.2d:%0.2d:%0.2d.%0.6d", hour, min, sec, tv_usec
#  end
#end

class AimPacket
  
  ## @debug and data_debug specify whether the AIM hex stream should be
  ## displayed, set it to "1" to display the data
  @debug = 0
  def data_debug(onoff)
    @debug = onoff
  end
  
  def decode_outgoing_aim_packet(packet)
    @packetdata = packet.tcp_data.to_s
    @buddyname_len = ''
    @buddyname = ''
    @buddyname_size = 0
    
    @features_len = ''
    @features_data = ''
    @features_data_size = 0
    
    @block_len = ''
    
    @data = ''
    @data_size = 0
    
    @empty_packet = 0
    
    offset = 0
    @empty_packet = 0
    d = @packetdata.unpack('H*')[0]
    if d.to_s.length == 0
      @empty_packet = 1
      return
    end
    puts "[+] Outgoing Data: #{d.to_s}" if @debug == 1
    
    offset = 52
    @buddyname_len = d[offset,2]
    offset += 2  ## buddyname_len size
    if (!@buddyname_len.nil?)
      @buddyname_size = 2 * @buddyname_len.hex
    end
    @buddyname = d[offset,@buddyname_size]
    offset += @buddyname_size + 12

    @features_len = d[offset,4]
    offset += 4 ## Features_len size
    if (!@features_len.nil?)
      @features_data_size = 2 * (@features_len.hex)
    end
    @features_data = d[offset,@features_data_size]
    offset += @features_data_size + 4

    @block_len = d[offset,4]
    offset += 12 ## 4 for block_len, 4 for charset and charsubset
    
    if (!@block_len.nil?)
      @data_size = (2 * @block_len.hex)
      if @data_size < 0
        @data_size = 0
      end
    end
    @data = d[offset,@data_size]
    
    
    if @data.nil? || @buddyname.length < 1 || @data[0,1] == "?"
      return
    end

    print "<#{packet.ip_src.to_s}> "
    print "<you> --> "
    @buddyname.scan(/../) {|a| print a.to_a.pack("H2")} unless @buddyname.nil?
    print ": "
    @data.scan(/../) {|a| print a.to_a.pack("H2")} unless @data.nil?
    print "\n"
    
  end
  
  def decode_incoming_aim_packet(packet)
    @buddyname_len = ''
    @buddyname = ''
    @buddyname_size = 0

    @features_len = ''
    @features_data = ''
    @features_data_size = 0

    @block_len = ''

    @data = ''
    @data_size = 0
    
    @empty_packet = 0
    @packetdata = packet.tcp_data.to_s
    
    offset = 0
    # convert to hex
    d = @packetdata.unpack('H*')[0]
    if d.to_s.length == 0
      @empty_packet = 1
      return
    end
    puts "[+] Incoming Data: #{d.to_s}" if @debug == 1
    
    offset = 52
    @buddyname_len = d[offset,2]
    offset += 2  ## buddyname_len size
    if (!@buddyname_len.nil?)
      @buddyname_size = 2 * @buddyname_len.hex
    end
    @buddyname = d[offset,@buddyname_size]
    offset += @buddyname_size
    
    offset += 4 ## Warning level for AIM user
    
    @tlv_count = d[offset,4] ## Very important
    offset += 4 ## Add tlv_count offset
    
    if !@tlv_count.nil?
      for @tlv in 1..@tlv_count.hex
        offset += 4 ## For the value_id
        @tlv_len = d[offset,4]
        ## Add 4 for the len plus the data in the TLV
        offset += 4
        offset += 2 * @tlv_len.hex unless @tlv_len.nil?
      end
    end
    
    offset += 4 ## Value ID for message body
    offset += 4 ## Length for message body
    offset += 4 ## Features
    
    @features_len = d[offset,4]
    offset += 4 ## Features_len size
    if (!@features_len.nil?)
      @features_data_size = 2 * (@features_len.hex)
    end
    offset += @features_data_size
    
    offset += 4 ## Block info

    @block_len = d[offset,4]
    offset += 12 ## 4 for block_len, 4 for charset and charsubset
    
    if (!@block_len.nil?)
      @data_size = (2 * @block_len.hex) - 8
      if @data_size < 0
        @data_size = 0
      end
    end
    @data = d[offset,@data_size]   
    
    if @data.nil? || @buddyname.length < 1 || @data[0,1] == "?"
      return
    end

    print "<#{packet.ip_dst.to_s}> "
    @buddyname.scan(/../) {|a| print a.to_a.pack("H2")} unless @buddyname.nil?
    print " --> <you>: "
    @data.scan(/../) {|a| print a.to_a.pack("H2")} unless @data.nil?
    print "\n"
  end

end


## The actual main part of the program
STDERR.puts "Use '-h' to display usage"
pcaplet = Pcaplet.new("-n -s 65536")
STDERR.puts "Capturing..."

## Filter, all AIM traffic runs on 5190
AIM_DATA  = Pcap::Filter.new('tcp and port 5190', pcaplet.capture)
pcaplet.add_filter(AIM_DATA)

pcaplet.each_packet { |pkt|
  ap = AimPacket.new

  ## Debug off, set to 1 to enable
  ap.data_debug(0)
  ## At the moment, have to differentiate between incoming and
  ## outgoing messages
  if (pkt.tcp_dport == 5190)
    ap.decode_outgoing_aim_packet(pkt)
  elsif (pkt.tcp_sport == 5190)
    ap.decode_incoming_aim_packet(pkt)
  end
}
pcaplet.close
