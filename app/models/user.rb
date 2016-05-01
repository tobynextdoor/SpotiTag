class User < ActiveRecord::Base
  has_many :taggings
  has_many :songs, :through => :taggings
  has_many :tags, :through => :taggings

  def self.system
    @@system ||= User.where(:name => "spotitag").first_or_create
  end

  def self.new_def(spotify_id, name)
    user = User.new(
      :spotify_id => spotify_id,
      :secret => SecureRandom.hex,
      :name => name)
    user.save
    user
  end

  def rspotify_user
    @rspotify_user ||= RSpotify::User.find(spotify_id)
  end
end
