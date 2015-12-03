require "bundler"
Bundler.require

server = Opal::Server.new do |s|
  s.append_path "app"
  s.append_path "vendor"

  s.source_map = true
  s.debug = true
  s.main = "application"
  s.index_path = "index.html.erb"
end

run server
