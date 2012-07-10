require 'timeline_fu/fires'
require 'timeline_fu/version'

ActiveRecord::Base.send :include, TimelineFu::Fires
