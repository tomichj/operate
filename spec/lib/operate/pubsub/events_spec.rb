require 'spec_helper'

module Operate
  module Pubsub
    describe Events do
      describe '#include?' do
        context 'string event: "foo"' do
          subject { Events.new 'foo' }
          it 'returns true for "foo"' do
            expect(subject.include?('foo')).to be_truthy
          end
          it 'returns true for :foo' do
            expect(subject.include?(:foo)).to be_truthy
          end
          it 'returns false for non-foo events' do
            expect(subject.include?('bar')).to be_falsey
            expect(subject.include?(:bar)).to be_falsey
          end
        end

        context 'symbol event: :foo' do
          subject { Events.new :foo }
          it 'returns true for "foo"' do
            expect(subject.include?('foo')).to be_truthy
          end
          it 'returns true for :foo' do
            expect(subject.include?(:foo)).to be_truthy
          end
          it 'returns false for non-foo events' do
            expect(subject.include?('bar')).to be_falsey
            expect(subject.include?(:bar)).to be_falsey
          end
        end

        context 'list of events: [:foo, "bar"]' do
          subject { Events.new [:foo, 'bar'] }
          it 'returns true for "foo"' do
            expect(subject.include?('foo')).to be_truthy
          end

          it 'returns true for :foo' do
            expect(subject.include?(:foo)).to be_truthy
          end

          it 'returns true for "bar"' do
            expect(subject.include?('bar')).to be_truthy
          end

          it 'returns true for :bar' do
            expect(subject.include?(:bar)).to be_truthy
          end

          it 'returns false otherwise' do
            expect(subject.include?('baz')).to be_falsey
            expect(subject.include?(:baz)).to be_falsey
          end
        end

        context 'regexp: /foo/' do
          subject { Events.new /foo/ }
          it 'returns true for "foo"' do
            expect(subject.include?('foo')).to be_truthy
          end

          it 'returns true for :foo' do
            expect(subject.include?(:foo)).to be_truthy
          end

          it 'returns false otherwise' do
            expect(subject.include?('bar')).to be_falsey
            expect(subject.include?(:bar)).to be_falsey
          end
        end

        context 'a class' do
          subject { Events.new Object.new }

          it 'raises ArgumentError' do
            expect { subject.include?('foo') }.to raise_error(ArgumentError)
          end
        end
      end

    end
  end
end
