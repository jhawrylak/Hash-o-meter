class PagesController < ApplicationController
  def new
    @filterword = params[:track][:filter]
    tl = Tweetload.first
    begin
    Process.kill("SIGTERM",tl.process) unless tl.nil?
    rescue
    end
    call_rake(:load_tweets, :pid => Process.pid, :track => @filterword)
    redirect_to :root
  end
  
  def plot_values
    @vals = []
    @times = []
    @filterword = ""
    @filterword = Tweetload.first.tracking unless Tweetload.first.nil?
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
      
      @tweets = []
      begin
      lid = Tweets.last.id 
      fid = Tweets.first.id
      (0...[(lid-fid)+1,5].min).each do
        @tweets << Tweets.find_by_id(rand((lid-fid)+1)+fid).text
      end
      rescue
        @tweets << ""
      end
    render :json => {:vals => @vals, :times => @times, :total => "#{@vals.sum} tweets in the past hour for the tag \"#{@filterword}\"", :tweets => @tweets}
  end
  
  def home    
  end
  
  private
  def minutes_ago(t)
    (60 - t.text.to_i + Time.now.min) % 60
  end
end
