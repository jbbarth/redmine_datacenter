#!/usr/bin/ruby

# Usage:
#   
#   if you have access to SMCli directly (replace the IP with one of your device controllers' IP) :
#
#   SMCli 192.168.0.200 -c 'show storagesubsystem profile;' | ./lib/tasks/generate_storage_fixtures.rb > test/fixtures/storage/DS4XXX.txt
#
#   or, if you have the profile already stored in a file :
#
#   cat /path/to/your/profile | ./lib/tasks/generate_storage_fixtures.rb > test/fixtures/storage/DS4XXX.txt
#   ./lib/tasks/generate_storage_fixtures.rb /path/to/your/profile > test/fixtures/storage/DS4XXX.txt

#file content
content = ARGF.read

#will help us scramble it all
def content.scan_uniq(regex, &block)
  i = 0
  self.scan(regex).uniq.each do |str|
    yield(str,i+=1) if block_given?
  end
end

#random char generator
def random_char(n=2,int='a'..'z')
  (1..n).map do
    int.to_a[rand(int.to_a.length)]
  end.join
end

#let's scramble logical drives names
content.scan_uniq /ld_\w+|\w+_LUN\w+/i do |str,i|
  content.gsub! str, "logical_drive_#{i}"
end
#and host groups, hosts, aliases
content.scan_uniq /(Host group|Host:|Alias:)\s+(\S+)/i do |str,i|
  type, name = str
  type = type.strip.gsub(":","").gsub(/[^a-z]/i,"_").downcase
  content.gsub! name, "#{type}_#{i}"
end
#and macadresses/world wide names
content.scan_uniq /(?:[0-9A-F]{2}:){3,}[0-9A-F]{2}/i do |str,i|
  chars = (0..9).to_a+('A'..'F').to_a
  content.gsub! str, str.split(":").map{|s|random_char(2,chars)}.join(":")
end
#and each suspect number (licence, etc.)
content.scan_uniq /[0-9A-F]{8,}/ do |str,i|
  #heuristic.. if more than 5 letters side by side, no doubt it's a word!
  unless str =~ /[A-F]{5}/
    chars = (0..9).to_a
    chars << ('A'..'F').to_a unless str =~ /^\d+$/ #use letters only if we replace str containing letters
    content.gsub! str, random_char(str.length,chars)
  end
end
#and PN / SN
content.scan_uniq /\b(?:PN|SN) ([0-9A-Z]{5,})/ do |str,i|
  chars = (0..9).to_a+('A'..'Z').to_a
  content.gsub! str.last, random_char(str.last.length,chars)
end
#and years
content.scan_uniq /199\d|20\d\d/ do |str,i|
  chars = (0..9).to_a
  content.gsub! str, "200#{random_char(1,chars)}"
end
#and IPs
content.scan_uniq /\b[0-9]{1,3}(?:\.[0-9]{1,3}){3}\b/ do |str,i|
  next if str =~ /^255.255/ #not netmasks
  next if str =~ /^0/       #firmwares etc.
  new_ip = "192.168.0."+random_char(1,(1..254).to_a)
  content.gsub! str, new_ip
end

#and now return the result
puts content
