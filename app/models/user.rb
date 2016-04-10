class User < ActiveRecord::Base
  has_many :songs, dependent: :destroy, autosave: true

  def self.new_def()
    user = User.new(:tags_string => "")
    user.save
    user
  end

  def create_song(spotify_id, tags)
    songs.create(
      :spotify_id => spotify_id,
      :tags_string => tags.join(";")
    )
  end

  def songs_for_tags(tags)
    songs.all.select do |song|
      (tags - song.tags).empty?
    end
  end

  def tags
    tags_string.split ";"
  end

  def add_tag(tag_name)
    update(:tags_string => (tags << tag_name).join(";"))
  end
end
