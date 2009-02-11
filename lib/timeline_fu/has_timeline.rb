module TimelineFu
  module HasTimeline
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      # Who's this timeline for? User? Person?
      # Go and put has_timeline in the model's class definition. 
      def has_timeline
        has_many :timeline_events, :as => :target
      end
    end
  end
end
