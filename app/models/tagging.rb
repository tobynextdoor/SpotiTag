class Tagging < ActiveRecord::Base
  belongs_to :song
  belongs_to :user
  belongs_to :tag
end