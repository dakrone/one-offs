#!/usr/bin/env ruby -w
# encoding: UTF-8
#
# A simply `p4 diff` output colorizer.

FILE_R = /^====\s+([\s\S]+)(#\d+) - ([\s\S]+) ====$/
POS_R  = /^(\d+[ad]\d+)$/
OUT_R  = /^< /
IN_R   = /^> /

## Escape sequences for colors
## Misc
$RESET = "\033[0m"
$BOLD = "\033[1m"
$BLINK = "\033[5m"

## Foreground colors
$BLACK = "\033[30m"
$RED = "\033[31m"
$GREEN = "\033[32m"
$BROWN = "\033[33m"
$BLUE = "\033[34m"
$MAGENTA = "\033[35m"
$CYAN = "\033[36m"
$WHITE = "\033[37m"

$stdin.each_line do |line|
  line.chomp!
  if line =~ FILE_R
    puts "#{$MAGENTA}" + line + "#{$RESET}"
  elsif line =~ POS_R
    puts "#{$CYAN}" + line + "#{$RESET}"
  elsif line =~ OUT_R
    puts "#{$RED}" + line + "#{$RESET}"
  elsif line =~ IN_R
    puts "#{$GREEN}" + line + "#{$RESET}"
  else
    puts line
  end
end
