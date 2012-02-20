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
  threads = []
  
  TweetStream::Client.new.track(word) do |status,client|
    #don't tie up our stream with the DB
    newthread = (Thread.new(status,word) { |status,trackword|
                   Tweets.new({:text => status.text,
                               :user => status.user.screen_name,
                               :time => status.created_at,
                               :filter => trackword
                               }).save
    })
    threads << newthread
    newthread.run
    $tweetCount = $tweetCount+1
    socket.print("#{status.text}")
    #clear out our stopped threads
    (threads.collect {|thread|
          if thread.alive?
             thread
               else
                 nil
               end
            }).compact! if threads.length > 500
        
    #if our rails process was killed,
    #clear out our threads, then stop the client
    begin
      Process.kill(0,pid)
    rescue Errno::ESRCH
      until threads.empty?
                    sleep 1 #
                    (threads = threads.map {|thread|
                       if thread.alive?
                         thread
                       else
                         nil
                       end
                    }).compact!
                  end
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
    t.delete
    exit(1)
  end
  
  begin
    socket = UNIXSocket.new('/tmp/echo.sock')

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
  rescue
  end
  #we're no longer the job
  t.delete
end
