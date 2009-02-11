require 'timeline_fu/has_timeline'
require 'timeline_fu/fires'

module TimelineFu  
end

ActiveRecord::Base.send(:include, TimelineFu::HasTimeline, TimelineFu::Fires)
