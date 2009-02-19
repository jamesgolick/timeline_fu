class TimelineEventGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate'
    end
  end
end
