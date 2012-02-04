require File.join(File.dirname(__FILE__),'/lib/HashometerHelper.rb')
include HashometerHelper

configfile = File.open(File.join(File.dirname(__FILE__),'../config/config.rb'), "r")
config = {}
while !configfile.eof?
  line = configfile.readline.chomp
  next if line[0] =='#'
  line = line.split("=").collect { |val| val.strip.gsub('"','') }
  config[line[0].to_sym] = line[1]
end
testconfig(config,:username)
testconfig(config,:password)
configfile.close
p config