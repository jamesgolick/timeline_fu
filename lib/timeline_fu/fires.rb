module TimelineFu
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def fires(event_type, opts)
        raise ArgumentError, "Argument :on is mandatory" unless opts.has_key?(:on)

        method_name = :"fire_#{event_type}_after_#{opts[:on]}"
        define_method(method_name) do
          create_options = [:actor, :subject, :secondary_subject].inject({}) do |memo, sym|
            memo[sym] = send(opts[sym]) if opts[sym]
            memo
          end
          create_options[:subject]  ||= self
          create_options[:event_type] = event_type.to_s

          TimelineEvent.create!(create_options)
        end

        send(:"after_#{opts[:on]}", method_name, :if => opts[:if])
      end
    end
  end
end
