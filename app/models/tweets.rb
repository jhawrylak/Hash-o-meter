class Tweets < ActiveRecord::Base
  attr_accessible :filter, :time, :user, :text, :ticount
end
