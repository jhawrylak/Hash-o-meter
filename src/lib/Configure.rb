module Configure
  def Configure.readconfig(file)
    configfile = File.open(file, "r")
    config = {}
    while !configfile.eof?
      line = configfile.readline.chomp
      next if line[0] =='#'
      line = line.split("=").collect { |val| val.strip.gsub('"','') }
      config[line[0].to_sym] = line[1]
    end
    configfile.close()
    config
  end
end