module Dictum
  module Pubsub
    class Registration
      attr_reader :on, :listener

      def initialize(listener, options)
        @listener = listener
        @on = Dictum::Pubsub::Events.new options[:on]
      end

      def broadcast(event, *args)
        listener.call(*args) if should_broadcast?(event)
      end

      private

      def should_broadcast?(event)
        on.include? event
      end
    end
  end
end
