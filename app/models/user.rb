class User < ActiveRecord::Base
  serialize :rspotify_hash
  has_many :songs, dependent: :destroy, autosave: true

  def self.new_def(spotify_id, rspotify_hash)
    user = User.new(
      :spotify_id => spotify_id,
      :rspotify_hash => rspotify_hash,
      :secret => SecureRandom.hex,
      :tags_string => "")
    user.save
    user
  end

  def rspotify_user
    @rspotify_user ||= RSpotify::User.new(rspotify_hash)
  end

  def add_song(spotify_id, tags)
    if songs.where(:spotify_id => spotify_id).empty?
      songs.create(
        :spotify_id => spotify_id,
        :tags_string => tags.join(";")
      )
    end
  end

  def songs_by_tags(tags)
    songs.all.select do |song|
      (tags.map(&:downcase) - song.tags.map(&:downcase)).empty?
    end
  end

  def songs_without_tags
    songs.where(:tags_string => "")
  end

  def tags
    tags_string.split ";"
  end

  def add_tag(tag_name)
    update(:tags_string => (tags << tag_name).join(";"))
  end
end
