Rails.application.routes.draw do
  root :to => 'application#index'

  get 'user/:user_id/:user_secret' => 'application#user'
  get 'user/:user_id/:user_secret/delete_option' => 'application#delete_option'
  get 'user/:user_id/:user_secret/delete' => 'application#delete'
  post 'user/:user_id/:user_secret/song/:song_id/set_tags' => 'application#set_tags'
  post 'user/:user_id/:user_secret/delete_songs' => 'application#delete_songs'
  post 'user/:user_id/:user_secret/add_music' => 'application#add_music'
  post 'user/:user_id/:user_secret/create_playlist' => 'application#create_playlist'

  get '/auth/spotify/callback', to: 'application#spotify_callback'

  get '*path' => redirect('/')
end
