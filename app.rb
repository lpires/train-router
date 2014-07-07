require 'rubygems'
require 'sinatra'
require 'rabl'
require 'active_support/core_ext'
require 'active_support/inflector'
require './app/train_router'
require './app/models/edge'


# Register RABL
Rabl.register!

router = TrainRouter.new

get '/edge' do
  @edges = router.nodes.values.select {|node| !node.empty?}
  @edges = @edges.flatten!

  render :rabl, :'api/edge/index'
end

post '/edge' do
  content_type :json
  @edge = router.connect Edge.new(params['src'].to_sym, params['dst'].to_sym, params['length'].to_i)

  render :rabl, :'api/edge/show'
end

post '/route' do

  @result = nil
  if params.has_key? 'path'
    path = (params[:path].kind_of? String) ? eval(params[:path]) : params[:path]
    @result = router.distance *path.map{|p| p.to_sym}

  else
    limits = {}
    limits[:steps] = params['steps'].to_i if params.has_key? 'steps'
    limits[:cost] = params['cost'].to_i if params.has_key? 'cost'

    method = :shortest_route
    if params[:count]
      method = params[:limit] == 1 ? :step_number : :path_number
    end

    condition = (params.key? :condition) ? ", #{params[:condition]}" : ''
    @result = eval "router.#{method}(Path.new(:#{params[:src]}), :#{params[:dst]}, #{limits}#{condition})"
  end
  render :rabl, :'api/route/create'
end