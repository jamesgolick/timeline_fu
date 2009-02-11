module TimelineFu
  module ActsAsEventTarget
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      # Who's this timeline for? User? Person?
      # Go and put acts_as_event_target in the model's class definition. 
      def acts_as_event_target
        has_many :timeline_events, :as => :target
      end
    end
  end
end
