require 'rspotify'

class LoginException < StandardError
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from LoginException, :with => :redirect_exception

  def index
    user_id = params[:user_id]
    unless user_id.nil?
      redirect_to "/user/#{user_id}"
    end
  end

  def user
    @filterable = true
    @user = fetch_user params[:user_id], params[:user_secret]

    @input_tags = (params[:tags] || "").split(",").map(&:strip)
    unless @input_tags.empty?
      start_time = Time.now.nsec
      @tags = Tag.where("lower(name) IN (?)", @input_tags.map(&:downcase)).to_a

      if @input_tags.count == @tags.count
        tag_ids = @tags.map(&:id)
        @songs = Song.joins(:tags).where('tags.id IN (?)', tag_ids).group("songs.id").having("COUNT(songs.id) >= ?", tag_ids.length)
        #maybe consider looking at http://www.monkeyandcrow.com/blog/tagging_with_active_record_and_postgres/

        #starting_tag = @tags.shift
        #@songs = @tags.inject(starting_tag.songs) do |songs, tag|
        #  songs & tag.songs
        #end
      end
      @query_duration = (Time.now.nsec - start_time) / 1000000
    end
    @songs ||= []
  end

  def add_music
    user = fetch_user params[:user_id], params[:user_secret]
    tags = params[:tags].split(",").map(&:strip).map do |tag_name|
      Tag.by_name tag_name
    end

    spotify_uri = params[:spotify_uri].split(":")
    type = spotify_uri[1]

    song_spotify_ids = if type == "track"
      [spotify_uri[2]]
    elsif type == "album"
      album = RSpotify::Album.find spotify_uri[2]
      album.tracks.map(&:id)
    elsif type == "artist"
      artist = RSpotify::Artist.find spotify_uri[2]
      artist.albums.each do |album|
        album.tracks.map(&:id)
      end.flatten
    elsif spotify_uri.length == 5 && spotify_uri[3] == "playlist"
      playlist = RSpotify::Playlist.find spotify_uri[2], spotify_uri[4]
      playlist.tracks.map(&:id)
    else
      []
    end.reject(&:nil?)

    song_spotify_ids.each do |song_spotify_id|
      song = Song.by_spotify_id song_spotify_id
      tags.each do |tag|
        song.tag_it tag, user
      end
    end

    redirect_to "/user/#{user.id}/#{user.secret}"
  end

  def add_tag
    user = fetch_user params[:user_id], params[:user_secret]
    if (song = Song.find(params[:song_id]))
      if (tag = Tag.find(params[:tag_id]))
        song.tag_it tag, user
      end
    end

    redirect_to "/user/#{user.id}/#{user.secret}"
  end

  def remove_tagging
    user = fetch_user params[:user_id], params[:user_secret]
    tagging_id = params[:tagging_id]
    if (tagging = Tagging.find(tagging_id)).user == user
      tagging.destroy
    end

    redirect_to "/user/#{user.id}/#{user.secret}"
  end

  def create_playlist
    user = fetch_user params[:user_id], params[:user_secret]
    playlist_name = params[:playlist_name]
    song_ids = params[:song_ids].split ","

    tracks = song_ids.map{|s| user.songs.find(s).rspotify_track}

    playlist = user.rspotify_user.create_playlist!(playlist_name)
    unless tracks.empty?
      playlist.add_tracks! tracks
    end

    redirect_to "/user/#{user.id}/#{user.secret}"
  end

  def delete_option
    @user = fetch_user params[:user_id], params[:user_secret]
  end

  def delete
    user = fetch_user params[:user_id], params[:user_secret]
    user.destroy
    redirect_to "/"
  end

  def spotify_callback
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    spotify_id = spotify_user.id
    user = User.where(:spotify_id => spotify_id).first
    if user.nil?
      user = User.new_def(spotify_id, spotify_user.to_hash)
    end
    redirect_to "/user/#{user.id}/#{user.secret}"
  end

  def fetch_user(user_id, user_secret)
    user = User.where(:id => user_id, :secret => user_secret).first
    if user.nil?
      raise LoginException.new
    end
    user
  end

  def redirect_exception(exception)
    redirect_to "/" unless performed?
  end
end
