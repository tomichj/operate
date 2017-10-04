require 'spec_helper'

module Operate
  module Pubsub
    RSpec.describe Publisher do
      describe '#on' do
        before do
          @pub = SimplePublisher.new
        end
        it 'raises error on nil events' do
          expect { @pub.on(nil) }.to raise_error(ArgumentError)
        end
        it 'raises error on nil block' do
          expect { @pub.on(:some_event) }.to raise_error(ArgumentError)
        end
      end

      describe '#broadcast' do
        context 'publisher with registered event handlers' do
          before do
            @first_ok = false
            @second_ok = false
            @pub = SimplePublisher.new
            @pub.on(:ok) { @first_ok = true }
            @pub.on(:ok, :something_else) { @second_ok = true }
            @pub.broadcast(:ok)
          end
          it 'broadcasts event to handler with single event registered' do
            expect(@first_ok).to be_truthy
          end
          it 'broadcasts event to handler with list of events registered' do
            expect(@second_ok).to be_truthy
          end
        end
      end

      class SimplePublisher
        include Operate::Pubsub::Publisher
      end
    end
  end
end