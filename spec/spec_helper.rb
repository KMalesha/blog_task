# frozen_string_literal: true

module RequestMethods
  def app
    Rails.application
  end

  def resp
    last_response
  end
end

ENV["RACK_ENV"] = ENV["RAILS_ENV"] = "test"

require 'database_cleaner'
require File.expand_path('../../config/environment', __FILE__)
require 'factory'

RSpec.configure do |config|
  config.include Rack::Test::Methods, type: :request
  config.include RequestMethods, type: :request

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.color = true
end
