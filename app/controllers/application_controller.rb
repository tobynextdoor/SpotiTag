require 'rspotify'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def index
    user_id = params[:user_id]
    unless user_id.nil?
      redirect_to "/user/#{user_id}"
    end
  end

  def user
    @user = User.find(params[:user_id])
    @input_tags = params[:tags] || ""
    @tags = @input_tags.delete(' ').split ","
    if @input_tags == "[[none]]"
      @songs = @user.songs_without_tags
    else
      @songs = @user.songs_by_tags(@tags)
    end
  end

  def add_tags
    user = User.find params[:user_id]
    song = user.songs.find params[:song_id]

    song.add_tags params[:tags].delete(' ').split(",")

    redirect_to "/user/#{user.id}"
  end

  def delete_song
    user = User.find params[:user_id]
    song_id = params[:song_id]
    if song_id == "all"
      user.songs.destroy_all
    end

    redirect_to "/user/#{user.id}"
  end

  def add_music
    user = User.find params[:user_id]
    tags = params[:tags].delete(' ').split(",")
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

    redirect_to "/user/#{user.id}"
  end

  def create_playlist
    user = User.find params[:user_id]
    playlist_name = params[:playlist_name]
    song_ids = params[:song_ids].split ","

    tracks = song_ids.map{|s| user.songs.find(s).rspotify_track}

    playlist = user.rspotify_user.create_playlist!(playlist_name)
    unless tracks.empty?
      playlist.add_tracks! tracks
    end

    redirect_to "/user/#{user.id}"
  end

  def spotify_callback
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    spotify_id = spotify_user.id
    user = User.where(:spotify_id => spotify_id).first
    if user.nil?
      user = User.new_def(spotify_id, spotify_user.to_hash)
    end
    redirect_to "/user/#{user.id}"
  end
end
