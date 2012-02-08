class PagesController < ApplicationController
  def home
    call_rake(:load_tweets, :pid => Process.pid, :track => "pizza") if Tweetload.first.nil?
    t = Tweets.find_by_sql("SELECT count(*) c, strftime('%M', time) text FROM Tweets t WHERE t.time > datetime('now','-60 minute') group by strftime('%M',time) ORDER BY TEXT ASC")
    
    @firstt = minutes_ago(t.first)
    @firstt = 60 if @firstt < 60
    
    @vals = []
    @times = []
    (0...(@firstt+1)).each do |i|
      @vals << 0
      @times << i.to_s
    end
    @times = @times.reverse
    t.each do |twt|
      mins = minutes_ago(twt)
      i = @times.index(mins.to_s)
      @vals[i] = twt.c
    end
    
    @total = @vals.sum
  end
  
  private
  def minutes_ago(t)
    (60 - t.text.to_i + Time.now.min) % 60
  end
end
