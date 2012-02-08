class Tweets < ActiveRecord::Base
  attr_accessible :name, :time, :userid, :text, :ticount
end
