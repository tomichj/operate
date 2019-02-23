module Operate

  #
  # A command-pattern implementation for controller actions, etc.
  #
  # `register` handlers with on().
  # `broadcast` results with broadcast().
  # `transaction` wraps ActiveRecord transactions.
  # `expose` to set a value from the handler block to the caller
  #
  module Command
    include Operate::Pubsub::Publisher

    class Error < StandardError; end

    def self.included(target)
      target.extend ClassMethods
    end

    module ClassMethods
      attr_reader :command_presenter
      
      # Call will initialize the class with *args and invoke instance method `call` with no arguments
      def call(*args, &block)
        command = new(*args)
        command.evaluate(&block) if block_given?
        command.call
      end
      
      # def presenter presenter
      #   @command_presenter = presenter
      #   self
      # end
    end

    def transaction(&block)
      return unless block_given?

      if defined?(ActiveRecord)
        ::ActiveRecord::Base.transaction(&block)
      else
        raise Error, 'Transactions are supported only with ActiveRecord'
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
    
    #
    # Expose a value within a handler block to the caller.
    # Sets attribute directly if available, or as an instance variable.
    #
    # RegisterAccount.call(@form) do
    #   on(:ok) { |user| expose(:user => user) }
    # end
    #
    def expose(presentation_data)
      presentation_data.each do |attribute, value|
        if @caller.respond_to?("#{attribute}=")
          @caller.public_send("#{attribute}=", value)
        else
          @caller.instance_variable_set("@#{attribute}", value)
        end
      end
    end
  end
end
