require "active_record"
require "spec_helper"

RSpec::Matchers.define :broadcast do |*expected_responses|
  match do |command_class|
    success = false
    command_class.call do
      expected_responses.each do |key|
        on(key) { success = true }
      end
    end
    success
  end

  match_when_negated do |command_class|
    success = true
    command_class.call do
      expected_responses.each do |key|
        on(key) { success = false }
      end
    end
    success
  end
end

RSpec.describe Operate do
  DB_ERROR = ActiveRecord::ActiveRecordError

  it 'has a version number' do
    expect(Operate::VERSION).not_to be nil
  end

  class TransactionCommand
    include Operate::Command
    def call
      transaction do
        begin
          ::ActiveRecord::Base.connection.execute "SELECT 1 + 1"
          broadcast(:ok)
        end
      end
    rescue DB_ERROR # Like this because we later unload ActiveRecord
      broadcast(:database_error)
    end
  end

  context 'with ActiveRecord' do
    context "connected" do
      before do
        ActiveRecord::Base.establish_connection adapter: :sqlite3, database: ":memory:"
      end

      example '#transaction works' do
        expect(TransactionCommand).to broadcast(:ok)
      end
    end

    context 'disconnected' do
      before do
        ActiveRecord::Base.remove_connection if ActiveRecord::Base.connected?
      end

      example '#transaction works and raises' do
        expect(TransactionCommand).to broadcast(:database_error)
      end
    end
  end

  context 'without ActiveRecord' do
    before do
      Object.send :remove_const, "ActiveRecord"
    end
    example '#transaction raises an error' do
      expect { TransactionCommand.call }.to raise_error(Operate::Command::Error,
                                                        "Transactions are supported only with ActiveRecord")
    end
  end
end
