# frozen_string_literal: true

require 'yaml'

# connect to db
begin
  db_conf = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]
  if db_conf
    DB = Sequel.connect(db_conf)
    DB.extension :pg_array
    DB.freeze
    Rails.logger.info("successfully connected to db") if Rails.logger
  else
    msg = "db config doesn't have config for #{Rails.env} environment"
    Rails.logger.error(msg) if Rails.logger
    raise StandardError, msg
  end
rescue Errno::ENOENT => e
  Rails.logger.error("db config error: #{e.message}") if Rails.logger
  raise
rescue Sequel::Error => e
  Rails.logger.error("db error: #{e.message}") if Rails.logger
  raise
end
