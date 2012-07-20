module TimelineFu
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def fires(event_type, opts)
        raise ArgumentError, 'Argument :on is mandatory' unless opts.has_key?(:on)

        # Array provided, set multiple callbacks
        if opts[:on].kind_of?(Array)
          opts[:on].each { |on| fires(event_type, opts.merge({on: on})) }
          return
        end

        on = opts.delete(:on)
        _if = opts.delete(:if)
        _unless = opts.delete(:unless)

        method_name = :"fire_#{event_type}_after_#{on}"
        define_method(method_name) do
          create_options = opts.keys.inject({}) do |memo, sym|
            if opts[sym]
              if opts[sym].respond_to?(:call)
                memo[sym] = opts[sym].call(self)
              elsif opts[sym] == :self
                memo[sym] = self
              elsif sym == :callback || sym == :event_class_name
                memo[sym] = opts[sym]
              else
                memo[sym] = send(opts[sym])
              end
            end
            memo
          end

          fire_event(event_type, create_options)
        end

        send(:"after_#{on}", method_name, if: _if, unless: _unless)
      end

      def fire_event(event_type, create_options)
        create_options[:subject] = self unless create_options.has_key?(:subject)
        create_options[:event_type] = event_type.to_s

        callback = create_options.delete(:callback)
        event_class_names = Array(create_options.delete(:event_class_name) || 'TimelineEvent')

        event_class_names.each do |class_name|
          event = class_name.classify.constantize.create!(create_options)

          if callback && self.respond_to?(callback)
            if [1,-1].include?(method(callback).arity)
              self.send(callback, event)
            elsif method(callback).arity == 0
              self.send(callback)
            end
          end
        end
      end
    end

    def fire_event(event_type, create_options)
      self.class.fire_event(event_type, create_options)
    end
  end
end
