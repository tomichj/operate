module Operate

  #
  # A command-pattern implementation for controller actions, etc.
  #
  # `register` handlers with on().
  # `broadcast` results with broadcast().
  # `transaction` wraps ActiveRecord transactions.
  #
  module Command
    include Operate::Pubsub::Publisher
    extend ActiveSupport::Concern

    class Error < StandardError; end

    module ClassMethods

      #
      # Call will initialize the class with *args and invoke `call` with no parameters.
      #
      def call(*args, &block)
        command = new(*args)
        command.evaluate(&block) if block_given?
        command.call
      end
    end

    def transaction(&block)
      return unless block_given?

      if defined?(ActiveRecord)
        ::ActiveRecord::Base.transaction(&block)
      else
        raise Error, "Transactions are supported only with ActiveRecord"
      end
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
