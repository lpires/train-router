Dir[File.join(".", "app/**/*.rb")].each do |f|
  require f
end

require 'sinatra'
require 'rack/test'
require './app.rb'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
set :views, File.dirname(__FILE__) + "/../views"

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
