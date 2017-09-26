require 'active_support/notifications'

module Dictum
  module Pubsub
    module Publisher

      # subscribe a block
      #
      # @example
      #   my_publisher.on(:order_created) { |args| ... }
      #
      # @return [self]
      def on(*events, &block)
        raise ArgumentError, 'must give at least one event' if events.empty?
        raise ArgumentError, 'must pass a block' unless block
        registrations << Dictum::Pubsub::Registration.new(block, on: events)
        self
      end

      # broadcasts an event
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

      # def self.included(base)
      #   base.extend(ClassMethods)
      # end
    end
  end
end