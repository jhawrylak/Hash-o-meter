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
require 'socket'
require File.join(File.dirname(__FILE__),'../Configure.rb')

desc "Run a job to load tweets to the db"
$tweetCount = 0
def trackTweets(pid,socket,word)
  
  TweetStream::Client.new.track(word) do |status,client|
    # puts "t-in"
    text = "#{status.text}"
    # text = nil
    time = Time.now
    filter = word
    user = status.user.screen_name
    newTweet = Tweets.new({:text => text,
                                :user => user,
                               :time => time,
                               :filter => filter
                               })
    newTweet.save
    $tweetCount = $tweetCount+1
    socket.print("#{text}")
    #clear out our stopped threads
    #if our rails process was killed,
    #clear out our threads, then stop the client
    begin
      Process.kill(0,pid)
    rescue Errno::ESRCH
      puts "ESRCH"
      client.stop
    end
  end
  
end

task :load_tweets => :environment do
  #ensure we are the only tweet-loading task running
  pid = ENV['PID'].to_i
  trackword = ENV["TRACK"] || "pizza" #yum
  t = Tweetload.first
  exit(1) unless t.nil?   #die if there is another :load_tweets
  #load this process as the tweet-loading process
  t = Tweetload.new({:process => Process.pid, :tracking => trackword})
  exit(1) unless t.save #if we can't mark ourselves, die
  #ensure there was no race condition
  if Tweetload.all.length > 1
    t.delete
    exit(1)
  end
  sql = ActiveRecord::Base.connection();
  sql.execute("PRAGMA synchronous = OFF")
  
  Signal.trap("TERM") do
    # puts "sigTERM"
    t.delete
    exit(1)
  end
  
  begin
    socket = UNIXSocket.new('/tmp/echo.sock')
  rescue
    sleep 1
    begin
      Process.kill(0,pid)
    rescue Errno::ESRCH
      exit
    end
    retry
  end
  
  begin
    #load our twitter API credentials from a file
    config = Configure.readconfig(
      File.join(File.dirname(__FILE__),'../../config/twitterconfig.rb'),
      :consumerkey,
      :consumersecret,
      :oauthkey,
      :oauthsecret
    )
    Tweets.delete_all

    #pass them along to tweetstream
    TweetStream.configure do |c|
      c.consumer_key = config[:consumerkey]
      c.consumer_secret = config[:consumersecret]
      c.oauth_token = config[:oauthkey]
      c.oauth_token_secret = config[:oauthsecret]
      c.auth_method = :oauth
      c.parser   = :yajl
    end
    
    trackTweets(pid,socket,trackword)
  rescue Exception => e
    puts "Exception: #{e.message}"
  end
  #we're no longer the job
  t.delete
end
