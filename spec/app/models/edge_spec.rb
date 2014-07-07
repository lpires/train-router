require 'spec_helper'

describe Edge do
  it 'should create a Edge and default length is 1' do
    edge = Edge.new :A, :B
    expect(edge.length).to eq(1)
  end
end