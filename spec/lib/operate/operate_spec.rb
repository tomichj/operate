require "active_record"
require "spec_helper"

RSpec.describe Operate do
  it 'has a version number' do
    expect(Operate::VERSION).not_to be nil
  end
end
