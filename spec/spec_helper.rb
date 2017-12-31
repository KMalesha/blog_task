# frozen_string_literal: true

ENV["RACK_ENV"] = ENV["RAILS_ENV"] = "test"

require 'database_cleaner'
require File.expand_path('../../config/environment', __FILE__)

RSpec.configure do |config|

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
