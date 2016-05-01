class Tagging < ActiveRecord::Base
  belongs_to :song
  belongs_to :user
  belongs_to :tag

  def self.find_specific(song, user, tag)
    Tagging.where(:song => song, :user => user, :tag => tag).first
  end
end
