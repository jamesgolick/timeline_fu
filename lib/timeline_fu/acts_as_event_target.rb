module TimelineFu
  module ActsAsEventTarget
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def acts_as_event_target
        has_many :timeline_events, :as => :target
      end
    end
  end
end
