class Song < ActiveRecord::Base
  has_many :taggings
  has_many :users, :through => :taggings
  has_many :tags, :through => :taggings

  def self.by_spotify_id(spotify_id)
    song = Song.find_by(:spotify_id => spotify_id)

    if song.nil?
      rspotify_track = RSpotify::Track.find spotify_id
      unless rspotify_track.nil?
        song = Song.new(:spotify_id => spotify_id)
        song.save
        name_tag = Tag.by_name "name:#{rspotify_track.name}"
        album_tag = Tag.by_name "album:#{rspotify_track.album.name}"
        artist_tags = rspotify_track.artists.map do |artist|
          Tag.by_name "artist:#{artist.name}"
        end
        (artist_tags << album_tag << name_tag).each do |tag|
          song.tag_it tag, User.system
        end
      end
    end

    song
  end

  def tag_it(tag, user)
    taggings.where(:user => user, :tag => tag).first_or_create
  end

  def tag_by_prefix(prefix)
    tags.where("name LIKE :prefix", prefix: "#{prefix}%")
  end

  def name
    tag_by_prefix("name:").first.name.split(":")[1]
  end

  def album
    tag_by_prefix("album:").first.name.split(":")[1]
  end

  def artist
    tag_by_prefix("artist:").map{|a| a.name.split(":")[1]}.join ", "
  end

  def tags_counts
    @tags ||= taggings.group_by{ |g| g.tag.name }.map do |tag_name, tag_taggings|
      [tag_name, tag_taggings.count]
    end.to_h
  end
end
