require 'spec_helper'
require 'parser'

describe 'My behaviour' do
  it 'should do something' do
    expect(Parser.new.always_true).to eq(false)
  end
end