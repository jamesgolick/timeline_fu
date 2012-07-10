module TimelineFu
  module Matchers
    class FireEvent
      def initialize(event_type, opts = {})
        @event_type = event_type
        @opts = opts
        @method = :"fire_#{@event_type}_after_#{@opts[:on]}"
      end

      def matches?(subject)
        @subject = subject
        defines_callback_method?
      end

      def defines_callback_method?
        if @subject.methods.include?(@method)
          true
        else
          @missing = "#{@subject.class.name} instance does not respond to #{@method}"
          false
        end
      end

      def description
        "fire a #{@event_type} event"
      end

      def expectation
        expected = "#{@subject.class.name} to #{description}"
      end

      def failure_message
        "Expected #{expectation} (#{@missing})"
      end

      def negative_failure_message
        "Did not expect #{expectation}"
      end
    end

    def fire_event(event_type, opts)
      FireEvent.new(event_type, opts)
    end
  end
end
