##########################################################
##########################################################
######                                              ######
######                                              ######
######    Loads tweets into the db                  ######
######    Singleton job                             ######
######                                              ######
######                                              ######
##########################################################
##########################################################

require 'rubygems'
require 'tweetstream'
require File.join(File.dirname(__FILE__),'../Configure.rb')

desc "Run a job to load tweets to the db"
task :load_tweets => :environment do
  #ensure we are the only tweet-loading task running
  pid = ENV['PID'].to_i
  t = Tweetload.first
  exit(1) unless t.nil?
  
  #load this process as the tweet-loading process
  t = Tweetload.new({:process => Process.pid})
  
  #
  config = Configure.readconfig(
    File.join(File.dirname(__FILE__),'../../config/twitterconfig.rb'),
    :consumerkey,
    :consumersecret,
    :oauthkey,
    :oauthsecret
  )

  TweetStream.configure do |c|
    c.consumer_key = config[:consumerkey]
    c.consumer_secret = config[:consumersecret]
    c.oauth_token = config[:oauthkey]
    c.oauth_token_secret = config[:oauthsecret]
    c.auth_method = :oauth
    c.parser   = :yajl
  end
  
  exit(1) unless t.save
  #ensure there was no race condition
  if Tweetload.all.length > 1
    t.delete
    exit(1)
  end
  
  running = true
  
  while running==true
    TweetStream::Client.new.track('pizza') do |status,client|
      (Thread.new(status) { |status|
      Tweets.new({:text => status.text,
                  :user => status.user.screen_name,
                  :time => status.created_at,
                  :filter=>"pizza"
      }).save
      }).run
    
      begin
        Process.kill(0,pid)
      rescue Errno::ESRCH
        running = false
        client.stop
      end
    end
  end
  t.delete
end

