require 'simplecov'
SimpleCov.start do
  add_filter "app.rb"
  add_group "Models", "models/"
end

require "bundler/setup"
Bundler.require(:default)


Dir["models/*.rb"].each do |file|
  require File.join(File.dirname(__FILE__), "..", file)
end

