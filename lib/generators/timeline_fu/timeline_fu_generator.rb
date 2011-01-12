require 'rails/generators'
require 'rails/generators/migration'

class TimelineFuGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path(File.join('..', '..', '..', 'generators', 'timeline_fu', 'templates'), File.dirname(__FILE__))


  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    copy_file 'model.rb', 'app/models/timeline_event.rb'
    migration_template 'migration.rb', 'db/migrate/create_timeline_events.rb'
  end
end
