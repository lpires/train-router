require 'spec_helper'

describe Path do
  it 'should create a Path and default nodes length is 1 with cost 0 and final false' do
    path = Path.new :A
    expect(path.nodes.length).to eq(1)
    expect(path.nodes).to eq([:A])
    expect(path.cost).to eq(0)
    expect(path.final).to eq(false)
  end
end