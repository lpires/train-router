require 'spec_helper'
require 'json'

describe 'Train Router App' do
  include Rack::Test::Methods

  before do
    post '/edge', :src=>:A, :dst=>:B, :length=>5
    post '/edge', :src=>:B, :dst=>:C, :length=>4
    post '/edge', :src=>:C, :dst=>:D, :length=>8
    post '/edge', :src=>:D, :dst=>:C, :length=>8
    post '/edge', :src=>:D, :dst=>:E, :length=>6
    post '/edge', :src=>:A, :dst=>:D, :length=>5
    post '/edge', :src=>:C, :dst=>:E, :length=>2
    post '/edge', :src=>:E, :dst=>:B, :length=>3
    post '/edge', :src=>:A, :dst=>:E, :length=>7
  end

  it "should had create edges" do
    expect(last_response.status).to eq(200)
    response = JSON.parse(last_response.body)
    expect(response.empty?).to be(false)
    expect(response).to eq({"edge"=>{"src"=>"A", "dst"=>"E", "length"=>7}})
  end

  it "should list edges" do
    get '/edge'
    expect(last_response.status).to eq(200)
    response = JSON.parse(last_response.body)
    expect(response).to eq([{"edge"=>{"src"=>"A", "dst"=>"B", "length"=>5}},
                            {"edge"=>{"src"=>"A", "dst"=>"D", "length"=>5}},
                            {"edge"=>{"src"=>"A", "dst"=>"E", "length"=>7}},
                            {"edge"=>{"src"=>"A", "dst"=>"B", "length"=>5}},
                            {"edge"=>{"src"=>"A", "dst"=>"D", "length"=>5}},
                            {"edge"=>{"src"=>"A", "dst"=>"E", "length"=>7}},
                            {"edge"=>{"src"=>"B", "dst"=>"C", "length"=>4}},
                            {"edge"=>{"src"=>"B", "dst"=>"C", "length"=>4}},
                            {"edge"=>{"src"=>"C", "dst"=>"D", "length"=>8}},
                            {"edge"=>{"src"=>"C", "dst"=>"E", "length"=>2}},
                            {"edge"=>{"src"=>"C", "dst"=>"D", "length"=>8}},
                            {"edge"=>{"src"=>"C", "dst"=>"E", "length"=>2}},
                            {"edge"=>{"src"=>"D", "dst"=>"C", "length"=>8}},
                            {"edge"=>{"src"=>"D", "dst"=>"E", "length"=>6}},
                            {"edge"=>{"src"=>"D", "dst"=>"C", "length"=>8}},
                            {"edge"=>{"src"=>"D", "dst"=>"E", "length"=>6}},
                            {"edge"=>{"src"=>"E", "dst"=>"B", "length"=>3}},
                            {"edge"=>{"src"=>"E", "dst"=>"B", "length"=>3}}])
  end

  it "should calculate path" do
    TrainRouter.any_instance.stub(:distance).with(:A,:B,:C).and_return(9)
    post '/route', :path=>[:A,:B,:C]
  end

  it "should call step_number" do
    TrainRouter.any_instance.stub(:step_number).with(kind_of(Path), :C, {:steps=>3})
    post '/route', :src=>:C, :dst=>:C, :steps=>3, :limit=>1, :count=>true
  end

  it "should call path_number" do
    TrainRouter.any_instance.stub(:path_number).with(kind_of(Path), :C, {:steps=>5})
    post '/route', :src=>:A, :dst=>:C, :steps=>5, :count=>true
  end

  it "should call shortest_route" do
    TrainRouter.any_instance.stub(:shortest_route).with(kind_of(Path), :B, {:steps=>5})
    post '/route', :src=>:B, :dst=>:B, :steps=>5
  end
end