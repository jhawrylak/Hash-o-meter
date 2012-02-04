require File.join(File.dirname(__FILE__),'/lib/HashometerHelper.rb')
require File.join(File.dirname(__FILE__),'/lib/Configure.rb')
include HashometerHelper

config = Configure.readconfig(File.join(File.dirname(__FILE__),'../config/config.rb'))
testconfig(config,:username)
testconfig(config,:password)
p config