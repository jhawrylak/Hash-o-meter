require './lib/HashometerHelper.rb'
include HashometerHelper

configfile = File.open('config/config.rb', "r")
config = {}
while !configfile.eof?
  line = configfile.readline.chomp
  next if line[0] =='#'
  line = configfile.readline.chomp.split("=").collect { |val| val.strip.gsub('"','') }
  config[line[0].to_sym] = line[1]
end
testconfig(config,:username)
testconfig(config,:password)
configfile.close
p config