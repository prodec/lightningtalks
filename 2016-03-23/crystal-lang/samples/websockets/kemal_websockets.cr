require "kemal"

ws "/" do |socket|
  socket.on_message do |message|
  end
end

Kemal.run
