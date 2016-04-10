Rails.application.routes.draw do
  root :to => 'application#index'

  get 'user/:user_id' => 'application#user'
  post 'user/:user_id/song/:song_id/add_tags' => 'application#add_tags'
  get 'user/:user_id/song/:song_id/delete' => 'application#delete_song'
  post 'user/:user_id/add_music' => 'application#add_music'
  post 'user/:user_id/create_playlist' => 'application#create_playlist'

  get '/auth/spotify/callback', to: 'application#spotify_callback'
end
