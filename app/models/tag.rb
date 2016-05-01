class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :songs, :through => :taggings
  has_many :users, :through => :taggings

  def self.by_name(tag_name)
    tag = Tag.where(:name => tag_name).first_or_create
  end
end
