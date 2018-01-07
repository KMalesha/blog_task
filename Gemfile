source 'https://rubygems.org'

ruby '2.5.0'

# gem "actionpack"
# gem "actionview"
gem 'activesupport'
gem 'dry-transaction'
gem 'dry-validation'
gem 'oj'
gem 'pg'
gem 'railties'
gem 'sequel'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'ffaker', require: false
  gem 'faraday', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'typhoeus', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'rspec'
  gem 'rspec-rails'
end
