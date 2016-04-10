class User < ActiveRecord::Base
  has_many :songs, dependent: :destroy, autosave: true

  def self.new_def()
    user = User.new(:tags_string => "")
    user.save
    user
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
      (tags - song.tags).empty?
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
