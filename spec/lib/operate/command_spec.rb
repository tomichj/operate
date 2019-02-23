require 'operate'
require 'spec_helper'

module Operate
  describe Command do
    describe '#call' do
      it 'registers response with no constructor args' do
        response = false
        SimpleCommand.call do
          on(:ok) { response = true }
        end
        expect(response).to be_truthy
      end

      it 'registers response using constructor args' do
        arg = '1234'
        response = nil
        WithConstructorCommand.call(arg) do
          on(:ok) { |msg| response = msg }
        end
        expect(response).to eq arg
      end

      it 'registers multiple handlers' do
        response = nil
        WithArgCommand.call do
          on(:ok) { raise 'should not be called' }
          on(:validation_failure) { |msg| response = msg }
        end
        expect(response).to eq WithArgCommand::MSG
      end

      it 'registers list of events' do
        received = false
        SimpleCommand.call do
          on(:one, :two, :ok) { received = true }
        end
        expect(received).to be_truthy
      end
    end
    
    describe '#expose' do
      context 'from caller without the attribute' do
        it 'sets the instance variable on the caller' do
          WithConstructorCommand.call('1234') do
            on(:ok) { |msg| expose(test_var: msg) }
          end
          expect(@test_var).to be_present
        end
      end
      context 'from controller with the attribute' do
        it 'sets the attribute on the caller' do
          @new_test_var = 'fail'
          WithConstructorCommand.call('1234') do
            on(:ok) { |msg| expose(new_test_var: msg) }
          end
          expect(@new_test_var).to eq '1234'
        end
      end
    end
  end
end

class WithConstructorCommand
  include Operate::Command
  def initialize(arg)
    @arg = arg
  end
  def call
    broadcast(:ok, @arg)
  end
end

class SimpleCommand
  include Operate::Command
  def call
    broadcast(:ok)
  end
end

class WithArgCommand
  include Operate::Command
  MSG = 'Oooh I failed'
  def call
    broadcast(:validation_failure, MSG)
  end
end
