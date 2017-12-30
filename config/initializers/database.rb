# frozen_string_literal: true

require 'yaml'

# connect to db
begin
  db_conf = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]
  if db_conf
    DB = Sequel.connect(db_conf)
    DB.freeze
    Rails.logger.info("successfully connected to db")
  else
    msg = "db config doesn't have config for #{Rails.env} environment"
    Rails.logger.error(msg)
    raise StandardError, msg
  end
rescue Errno::ENOENT => e
  Rails.logger.error("db config error: #{e.message}")
  raise
rescue Sequel::Error => e
  Rails.logger.error("db error: #{e.message}")
  raise
end

# check outstanding migrations
begin
  Sequel.extension :migration
  Sequel::Migrator.check_current(DB, "#{Rails.root}/db/migrations")
end
