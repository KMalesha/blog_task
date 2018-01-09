require 'etc'
workers workers Etc.nprocessors
threads 4, 4

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  DB.disconnect
end
