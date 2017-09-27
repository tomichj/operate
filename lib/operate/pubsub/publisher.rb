require 'active_support/notifications'

module Operate
  module Pubsub

    #
    # A Command uses Publisher to register event handlers and broadcast to them.
    #
    module Publisher

      # Subscribe a block
      #
      # @example
      #   my_publisher.on(:order_created) { |args| ... }
      #
      # @return [self]
      def on(*events, &block)
        raise ArgumentError, 'must give at least one event' if events.empty?
        raise ArgumentError, 'must pass a block' unless block
        registrations << Operate::Pubsub::Registration.new(block, on: events)
        self
      end

      # Broadcasts an event
      #
      # @example
      #   def call
      #     # ...
      #     broadcast(:finished)
      #   end
      #
      # @return [self]
      def broadcast(event, *args)
        registrations.each do |registration|
          registration.broadcast(clean_event(event), *args)
        end
        self
      end

      private

      def registrations
        @registrations ||= Set.new
      end

      def clean_event(event)
        event.to_s.gsub('-', '_')
      end
    end
  end
end
