class PagesController < ApplicationController
  def home
    call_rake(:load_tweets, :pid => Process.pid)
  end
end
