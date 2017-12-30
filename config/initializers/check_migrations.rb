# frozen_string_literal: true

# check outstanding migrations
begin
  Sequel.extension :migration
  Sequel::Migrator.check_current(DB, "#{Rails.root}/db/migrations")
end
