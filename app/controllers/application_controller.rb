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

    @input_tags = params[:tags] || ""
    @tags = @input_tags.split " "
    if @input_tags == "[[none]]"
      @songs = @user.songs_without_tags
    else
      @songs = @user.songs_by_tags(@tags)
    end

    songs_to_be_fetched = @songs.reject(&:rspotify_track_is_cached?).
      map{|s| [s.spotify_id, s]}.
      to_h
    songs_ids_fetch = songs_to_be_fetched.keys
    unless songs_ids_fetch.empty?
      songs_ids_fetch.each_slice(50).to_a.each do |song_ids|
        RSpotify::Track.find(song_ids).each do |track|
          Song.rspotify_track_cache[track.id] = track
        end
      end
    end
  end

  def set_tags
    user = fetch_user params[:user_id], params[:user_secret]
    song = user.songs.find params[:song_id]

    song.add_tags params[:tags].split(" "), true

    redirect_to "/user/#{user.id}/#{user.secret}"
  end

  def delete_song
    user = fetch_user params[:user_id], params[:user_secret]
    song_id = params[:song_id]
    if song_id == "all"
      user.songs.destroy_all
    end

    redirect_to "/user/#{user.id}/#{user.secret}"
  end

  def add_music
    user = fetch_user params[:user_id], params[:user_secret]
    tags = params[:tags].split(" ")
    spotify_uri = params[:spotify_uri].split(":")
    type = spotify_uri[1]
    if type == "track"
      user.add_song spotify_uri[2], tags
    elsif type == "album"
      album = RSpotify::Album.find spotify_uri[2]
      album.tracks.each do |track|
        user.add_song track.id, tags
      end
    elsif type == "artist"
      artist = RSpotify::Artist.find spotify_uri[2]
      artist.albums.each do |album|
        album.tracks.each do |track|
          user.add_song track.id, tags
        end
      end
    elsif spotify_uri.length == 5 && spotify_uri[3] == "playlist"
      playlist = RSpotify::Playlist.find spotify_uri[2], spotify_uri[4]
      playlist.tracks.each do |track|
        user.add_song track.id, tags
      end
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
    redirect_to "/user/#{user.id}/#{user.secret}/delete_option"
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
