require 'cgi'
require 'rspotify'

class Song < ActiveRecord::Base
  belongs_to :user

  def self.rspotify_track_cache
    @@rspotify_track_cache ||= {}
  end

  def rspotify_track
    Song.rspotify_track_cache[spotify_id]
  end

  def rspotify_track_is_cached?
    !Song.rspotify_track_cache[spotify_id].nil?
  end

  def tags
    tags_string.split ";"
  end

  def add_tag(tag_name)
    unless tags.include? tag_name
      self.tags_string = (tags << tag_name).join ";"
      save
    end
  end

  def add_tags(tags, remove_old = false)
    if remove_old
      self.tags_string = ""
    end
    tags.each{|tag| add_tag tag}
  end

  def spotify_uri
    "spotify:track:#{spotify_id}"
  end

  def url_encoded_spotify_uri
    CGI.escape spotify_uri
  end
end
