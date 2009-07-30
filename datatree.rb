#!/usr/bin/env ruby -w
# encoding: UTF-8
#
# Spawn trees of data given some seed data.

##############################
# These options are editable #
##############################
# Maximum files per directory
FILE_PER_DIR = 1000

# How many seed files make up a generated file
FILE_PARTS   = 10

# 1kb will be added to this so that it reads more than 0 bytes
READ_AMOUNT  = 5096

# Viable extenstions
EXTENSIONS   = ["txt", "doc", "xls", "docx", "rtf", "png", "jpg", "html",
                "exe", "bin", "bat", "c", "cxx", "h", "cc", "gif", "zip",
                "tar", "gz", "tar.gz", "dmg", "iso"]
###############################
# Do not edit below this line #
###############################


require 'find'



# Print usage
def usage
  STDERR.puts <<EOF
Usage:
  #{File.basename(__FILE__)} <seed_dir> <dest_dir> <# of files>

Edit #{__FILE__} to change the other constants for now.
EOF
exit
end


begin
  SEED_DIR   = ARGV.shift
  DEST_DIR   = ARGV.shift
  FILE_NUM   = Integer(ARGV.shift)
  raise unless FILE_NUM > 0
rescue
  usage
end



puts "SEED_DIR     = #{SEED_DIR}"
puts "DEST_DIR     = #{DEST_DIR}"
puts "FILE_NUM     = #{FILE_NUM}"
puts "FILE_PER_DIR = #{FILE_PER_DIR}"
puts "FILE_PARTS   = #{FILE_PARTS}"
puts "READ_AMOUNT  = #{READ_AMOUNT}"
puts "EXTENSIONS   = #{EXTENSIONS.inspect}"



seed_files = []
Find.find(SEED_DIR) do |f|
  seed_files << f if File.file? f
end
puts "Found #{seed_files.size} seed files."



FILE_NUM.times do |n|

  # Generate a filename and random extension from our list
  dir_name = DEST_DIR + "/" + "dir" + (n / FILE_PER_DIR).to_s
  Dir.mkdir dir_name unless File.directory? dir_name
  file_name = "file_#{n}" + "." + EXTENSIONS[(n + rand(EXTENSIONS.size)) % EXTENSIONS.size]
  file_path = dir_name + "/" + file_name
  puts "Creating file #{file_path}..."


  # Grab random data from random files
  file_data = ""
  FILE_PARTS.times do |p|
    rfile = seed_files[rand(seed_files.size)]
    #puts "Using seed file #{rfile}..."
    File.open(rfile, "r") do |file|
      offset = File.size(rfile) % (1 + rand(File.size(rfile)))
      file.seek(offset)
      file_data << file.readpartial(rand(READ_AMOUNT) + 1024)
    end
  end


  File.open(file_path, "w") do |file|
    file.puts file_data
  end
end
