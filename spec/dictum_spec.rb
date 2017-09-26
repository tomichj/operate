require "spec_helper"

RSpec.describe Dictum do
  it 'has a version number' do
    expect(Dictum::VERSION).not_to be nil
  end

  it 'works' do
    Testo.call() do
      on(:ok)    { puts "GOT OK!" }
      on(:error) { puts "GOT ERROR!" }
    end
  end

  class Testo < Dictum::Command
    def call
      broadcast(:error)
    end
  end
end
