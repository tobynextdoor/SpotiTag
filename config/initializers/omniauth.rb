require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, "aa71623452a3451380304c833ccd5aef", "98cf23b224e54063996e8d1d5d42d2d9", scope: 'user-read-email playlist-modify-public user-library-read'
end
