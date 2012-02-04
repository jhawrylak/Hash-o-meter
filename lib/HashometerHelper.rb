module HashometerHelper
  def testconfig(hash,key)
    abort("Must have #{key.to_s} in config/config.rb in the form of #{key.to_s} = \"#{key.to_s}\"") if hash[key].nil?
  end
end