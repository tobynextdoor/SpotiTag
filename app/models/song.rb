require 'cgi'
require 'rspotify'
#http://railscasts.com/episodes/47-two-many-to-many?autoplay=true
class Song < ActiveRecord::Base
  serialize :tags_hash
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

  def tags(only_id, min_amount = 1)
    valid_tags = tags_hash.select do |tag_id, amount|
      amount >= min_amount
    end

    if only_id
      valid_tags.map{|tag_id, amount| tag_id}
    else
      valid_tags
    end
  end

  def add_tag(tag_id, should_save = true)
    tags_hash[tag_id] = (tags_hash[tag_id] || 0) + 1
    save if should_save
  end

  def add_tags(tag_ids, remove_old = false)
    if remove_old
      self.tags_hash = {}
    end
    tag_ids.each{|tag_id| add_tag tag_id, false}
    save
  end

  def spotify_uri
    "spotify:track:#{spotify_id}"
  end

  def url_encoded_spotify_uri
    CGI.escape spotify_uri
  end
end
