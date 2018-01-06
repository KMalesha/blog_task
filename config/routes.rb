Rails.application.routes.draw do
  post '/posts/create', to: 'application#create_post'
  post '/posts/rate', to: 'application#rate_post'
  get '/posts/top', to: 'application#top_posts'
  get '/authors/with_same_ip', to: 'application#authors_with_same_ip'
end
