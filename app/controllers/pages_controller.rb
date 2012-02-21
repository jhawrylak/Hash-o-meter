class PagesController < ApplicationController
  def new
    @filterword = "pizza"
    call_rake(:load_tweets, :pid => Process.pid, :track => @filterword) if Tweetload.first.nil?
    redirect_to :root
  end
  
  def plot_values
    @vals = []
    @times = []
    t = Tweets.find_by_sql("SELECT count(*) c, strftime('%M', time) text FROM Tweets t WHERE t.time > datetime('now','-1 hour') group by strftime('%M',time) ORDER BY TEXT ASC")
    if t.empty?
      @firstt = 10
      @total = 0
      (0..10).each do |i|
        @vals << 0
        @times << i.to_s
      end
    # @times.reverse
    else
      @firstt = minutes_ago(t.first)
      @firstt = 10 if @firstt < 10
      (0..@firstt).each do |i|
        @vals << 0
        @times << i.to_s
      end
      @times = @times.reverse
        t.each do |twt|
          mins = minutes_ago(twt)
          i = @times.index(mins.to_s)
          @vals[i] = twt.c || 0 unless i.nil?
        end
      end
    render :json => {:vals => @vals, :times => @times}
  end
  
  def home    
    @firstt = 10
    @total = 0
    @vals = []
    @times = []
    @tweets = []
    
    t = Tweets.find_by_sql("SELECT count(*) c, strftime('%M', time) text FROM Tweets t WHERE t.time > datetime('now','-1 hour') group by strftime('%M',time) ORDER BY TEXT ASC")
    # t = []
    #first call, probably
    if t.empty?
      @firstt = 10
      @total = 0
      (0..10).each do |i|
        @vals << 0
        @times << i.to_s
      end
      # @times.reverse
      return
    end
    
    @filterword = Tweetload.first.tracking unless Tweetload.first.nil?
    @firstt = minutes_ago(t.first)
    @firstt = 10 if @firstt < 10

    (0..@firstt).each do |i|
      @vals << 0
      @times << i.to_s
    end
    @times = @times.reverse
    
    t.each do |twt|
      mins = minutes_ago(twt)
      i = @times.index(mins.to_s)
      @vals[i] = twt.c || 0 unless i.nil?
    end
    lid = Tweets.last.id
    fid = Tweets.first.id
    (0...[lid-fid,5].min).each do
      @tweets << Tweets.find_by_id(rand((lid-fid))+fid)
    end
    @total = @vals.sum
  end
  
  private
  def minutes_ago(t)
    (60 - t.text.to_i + Time.now.min) % 60
  end
end
