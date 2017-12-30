# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, "db/migrations", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(db, "db/migrations")
    end
  end

  desc "Create migration"
  task :create_migration, :name do |t, args|
    if args[:name]
      File.new("db/migrations/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{args[:name]}.rb", "w").close
    else
      puts "name is blank"
    end
  end
end
