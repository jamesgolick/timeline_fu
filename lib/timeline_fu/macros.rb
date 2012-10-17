module TimelineFu
  module Macros
    def should_fire_event(event_type, opts = {})
      should "fire #{event_type} on #{opts[:on]}" do
        matcher = fire_event(event_type, opts)

        assert_accepts matcher, event_name
      end
    end

    def should_not_fire_event(event_type, opts = {})
      should "fire #{event_type} on #{opts[:on]}" do
        matcher = fire_event(event_type, opts)

        assert_rejects matcher, event_name
      end
    end

    private

    def event_name
      self.class.name.gsub(/Test$/, '').constantize
    end

  end
end
