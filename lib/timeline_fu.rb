require 'active_record'

module TimelineFu
  autoload :Fires, 'timeline_fu/fires'
end

ActiveRecord::Base.send(:include, TimelineFu::Fires)
