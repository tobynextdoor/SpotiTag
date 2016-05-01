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
        name_tag = Tag.name_tag rspotify_track.name
        album_tag = Tag.album_tag rspotify_track.album.name
        artist_tags = rspotify_track.artists.map do |artist|
          Tag.artist_tag artist.name
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

  def tags_by_prefix(prefix)
    tags.where("name LIKE :prefix", prefix: "#{prefix}%")
  end

  def name
    if tag = tags_by_prefix(Tag.prefix :name).first
      tag.name.split(":")[1]
    else
      ""
    end
  end

  def album
    if tag = tags_by_prefix(Tag.prefix :album).first
      tag.name.split(":")[1]
    else
      ""
    end
  end

  def artists
    tags_by_prefix(Tag.prefix :artist).map do |tag|
      tag.name.split(":")[1]
    end
  end

  def tags_counts
    @tags ||= taggings.group_by{ |g| g.tag }.map do |tag, tag_taggings|
      [tag, tag_taggings.count]
    end.to_h
  end
end
