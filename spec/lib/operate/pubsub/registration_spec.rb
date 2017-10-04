require 'spec_helper'

module Operate
  module Pubsub
    describe Registration do
      before(:each) do
        @listener = double('listener')
        @registration = Operate::Pubsub::Registration.new(@listener, on: :ok)
      end
      it 'broadcasts to interested listeners' do
        expect(@listener).to receive(:call)
        @registration.broadcast(:ok)
      end
      it 'does not broadcast to uninterested listeners' do
        expect(@listener).to_not receive(:call)
        @registration.broadcast(:not_ok)
      end
    end
  end
end
