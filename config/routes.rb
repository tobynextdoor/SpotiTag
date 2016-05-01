Rails.application.routes.draw do
  root :to => 'application#index'

  get 'user/:user_id/:user_secret' => 'application#user'
  get 'user/:user_id/:user_secret/delete_option' => 'application#delete_option'
  get 'user/:user_id/:user_secret/delete' => 'application#delete'
  get 'user/:user_id/:user_secret/tagging/:tagging_id/remove' => 'application#remove_tagging'
  get 'user/:user_id/:user_secret/song/:song_id/tag/:tag_id/add' => 'application#add_tag'
  post 'user/:user_id/:user_secret/add_music' => 'application#add_music'
  post 'user/:user_id/:user_secret/create_playlist' => 'application#create_playlist'

  get '/about' => 'application#about'
  get '/terms' => 'application#terms'
  get '/privacy' => 'application#privacy'

  get '/auth/spotify/callback', to: 'application#spotify_callback'

  get '*path' => redirect('/')
end
