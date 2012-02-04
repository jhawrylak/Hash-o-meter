module Configure
  def Configure.readconfig(file)
    configfile = File.open(file, "r")
    config = {}
    while !configfile.eof?
      line = configfile.readline.chomp
      next if line[0].chr =='#'
      line = line.split("=").collect { |val| val.strip.gsub('"','') }
      config[line[0].to_sym] = line[1]
    end
    configfile.close()
    config
  end
   
  def Configure.testconfig(hash,key)
    abort("Must have #{key.to_s} in config/config.rb in the form of #{key.to_s} = \"#{key.to_s}\"") if hash[key].nil?
  end
end