require "bundler/setup"
Bundler.require(:default)
Dir["models/*.rb"].each do |file|
  load file
end
