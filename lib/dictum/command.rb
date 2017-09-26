require 'active_support/concern'
require 'dictum/pubsub/publisher'
require 'dictum/pubsub/events'
require 'dictum/pubsub/registration'

module Dictum

  #
  # A command.
  #
  module Command
    include Dictum::Pubsub::Publisher
    extend ActiveSupport::Concern

    module ClassMethods
      def call(*args, &block)
        command = new(*args)
        command.evaluate(&block) if block_given?
        command.call
      end
    end

    def transaction(&block)
      ActiveRecord::Base.transaction(&block) if block_given?
    end

    def evaluate(&block)
      @caller = eval('self', block.binding)
      instance_eval(&block)
    end

    def method_missing(method_name, *args, &block)
      if @caller.respond_to?(method_name, true)
        @caller.send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @caller.respond_to?(method_name, include_private)
    end
  end
end
