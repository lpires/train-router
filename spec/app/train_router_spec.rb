require 'spec_helper'

describe TrainRouter do
  let(:graph) {TrainRouter.new}

  it 'should create TrainRouter' do
    expect(graph.nodes.empty?).to be(true)
  end

  it 'should add/get a node' do
    graph.add :A
    expect(graph.get(:A).kind_of? Array).to be(true)
    expect(graph.nodes.length).to eql(1)
  end

  it 'should connect node' do
    graph.connect Edge.new(:A, :B)
    edges = graph.get(:A)
    expect(edges.length).to eq(1)
    expect(edges.last.src).to eq(:A)
    expect(edges.last.dst).to eq(:B)
    expect(edges.last.length).to eq(1)
  end

  describe('#distance') do
    let(:graph) do
      test_graph = TrainRouter.new
      test_graph.connect Edge.new(:A, :B, 5)
      test_graph.connect Edge.new(:B, :C, 4)
      test_graph.connect Edge.new(:C, :D, 8)
      test_graph.connect Edge.new(:D, :C, 8)
      test_graph.connect Edge.new(:D, :E, 6)
      test_graph.connect Edge.new(:A, :D, 5)
      test_graph.connect Edge.new(:C, :E, 2)
      test_graph.connect Edge.new(:E, :B, 3)
      test_graph.connect Edge.new(:A, :E, 7)
      test_graph
    end

    it 'should calculate distance a route A-B-C' do
      cost = graph.distance :A,:B,:C
      expect(cost).to eq(9)
    end

    it 'should calculate distance a route A-D' do
      cost = graph.distance :A,:D
      expect(cost).to eq(5)
    end

    it 'should calculate distance a route A-D-C' do
      cost = graph.distance :A,:D,:C
      expect(cost).to eq(13)
    end

    it 'should calculate distance a route A-E-B-C-D' do
      cost = graph.distance :A,:E,:B,:C,:D
      expect(cost).to eq(22)
    end

    it 'should calculate distance a route A-E-D' do
      cost = graph.distance :A,:E,:D
      expect(cost).to eq(-1)
    end
  end

  describe('#route') do
    let(:graph) do
      test_graph = TrainRouter.new
      test_graph.connect Edge.new(:A, :B, 5)
      test_graph.connect Edge.new(:B, :C, 4)
      test_graph.connect Edge.new(:C, :D, 8)
      test_graph.connect Edge.new(:D, :C, 8)
      test_graph.connect Edge.new(:D, :E, 6)
      test_graph.connect Edge.new(:A, :D, 5)
      test_graph.connect Edge.new(:C, :E, 2)
      test_graph.connect Edge.new(:E, :B, 3)
      test_graph.connect Edge.new(:A, :E, 7)
      test_graph
    end

    it 'should calculate the number of steps trips from C to C with a max of 3' do
      expect(graph.step_number(Path.new(:C), :C, {:steps=>3})).to eq(2)
    end

    it 'should calculate the number of trips from A to C with exactly 4' do
      expect(graph.path_number(Path.new(:A), :C, {:steps=>5})).to eq(3)
    end

    it 'should calculate the shortest route from A to C' do
      expect(graph.shortest_route(Path.new(:A), :C)).to eq(9)
    end

    it 'should calculate the shortest route from B to B' do
      expect(graph.shortest_route(Path.new(:B), :B)).to eq(9)
    end

    it 'should calculate the number of trips from C to C with a max cost of 30' do
      expect(graph.path_number(Path.new(:C), :C, {:cost=>29}, TrainRouter::UNTIL)).to eq(7)
    end

  end

end