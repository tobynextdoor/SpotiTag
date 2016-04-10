Rails.application.routes.draw do
  root :to => 'application#index'

  get 'user/:user_id/:user_secret' => 'application#user'
  post 'user/:user_id/:user_secret/song/:song_id/add_tags' => 'application#add_tags'
  get 'user/:user_id/:user_secret/song/:song_id/delete' => 'application#delete_song'
  post 'user/:user_id/:user_secret/add_music' => 'application#add_music'
  post 'user/:user_id/:user_secret/create_playlist' => 'application#create_playlist'

  get '/auth/spotify/callback', to: 'application#spotify_callback'

  get '*path' => redirect('/')
end
