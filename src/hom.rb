require File.join(File.dirname(__FILE__),'/lib/HashometerHelper.rb')
require File.join(File.dirname(__FILE__),'/lib/Configure.rb')
require 'rubygems'
require 'tweetstream'
include HashometerHelper

config = Configure.readconfig(File.join(File.dirname(__FILE__),'../config/config.rb'))
Configure.testconfig(config,:consumerkey)
Configure.testconfig(config,:consumersecret)
Configure.testconfig(config,:oauthkey)
Configure.testconfig(config, :oauthsecret)

TweetStream.configure do |c|
  c.consumer_key = config[:consumerkey]
  c.consumer_secret = config[:consumersecret]
  c.oauth_token = config[:oauthkey]
  c.oauth_token_secret = config[:oauthsecret]
  c.auth_method = :oauth
  c.parser   = :yajl
end

  
d = TweetStream::Client.new


d.track('pizza','pasta') do |status|
  # The status object is a special Hash with
  # method access to its keys.
  puts "#{status.text}"
  d.stop
end

