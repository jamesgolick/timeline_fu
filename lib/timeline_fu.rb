require 'timeline_fu/acts_as_event_target'
require 'timeline_fu/fires'

module TimelineFu  
end

ActiveRecord::Base.send(:include, TimelineFu::ActsAsEventTarget, TimelineFu::Fires)
