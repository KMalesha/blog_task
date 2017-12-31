Rails.application.routes.draw do
  post '/posts/create'#, as: 'posts#create'
  post '/posts/rate'#, as: 'posts#rate'
  get '/posts/top'#, as: 'posts#top'
  get '/isp/different'#, as: 'ips#different'
end
