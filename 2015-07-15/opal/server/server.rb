# coding: utf-8
require "bundler/setup"
require "reel"
require "celluloid/autostart"

module DrawSomething
  class Endpoint < Reel::Server::HTTP
    def initialize(host = "0.0.0.0", port = 7331)
      super(host, port, &method(:on_connection))

      @coordinator = Coordinator.new
    end

    attr_reader :coordinator
    private :coordinator

    def on_connection(connection)
      connection.each_request do |request|
        if request.websocket?
          connection.detach
          add_player(request.websocket)
        end
      end
    end

    def add_player(socket)
      coordinator.async.add_player(socket)
    end
  end

  class Coordinator
    include Celluloid
    include Celluloid::Notifications

    def initialize
      @players = []
      @drawing = nil
      @word    = next_word
    end

    def add_player(socket)
      player = Player.new(@players.size + 1, Actor.current, socket)
      player.async.send_setup(@word)

      promote_to_drawing(player.id) if @players.empty?

      @players << player
    end

    def promote_to_drawing(player_id)
      publish "player_drawing", player_id
    end

    def new_word
      @word = next_word
      publish "new_word", @word
    end

    def guess(player_id, guess)
      return if guess.downcase.strip != @word

      new_word
      promote_to_drawing(player_id)
    end

    def next_word
      %w(abelha uva tênis carro fogueira).sample
    end
  end

  class Player
    include Celluloid
    include Celluloid::Notifications

    def initialize(id, coordinator, socket)
      @id      = id
      @control = PlayerConnection.new_link(Actor.current, socket)
      @socket  = socket
      @drawing = false
      @coordinator = coordinator

      subscribe "new_word", :send_word
      subscribe "player_drawing", :player_drawing
      subscribe "switch_color", :switch_color
      subscribe "line_to", :line_to
      subscribe "start_line", :start_line
      subscribe "end_line", :end_line
    end

    attr_reader :id

    def player_drawing(_, player_id)
      @socket << { command: :player_drawing, player_id: player_id }.to_json
      @drawing = player_id == @id
    end

    def send_setup(word)
      @socket << { command: :setup, id: @id, word: word }.to_json
    end

    def line_to(_, player_id, x, y)
      return if player_id == id

      @socket << { command: :line_to, x: x, y: y }.to_json
    end

    def start_line(_, player_id, x, y)
      return if player_id == id

      @socket << { command: :start_line, x: x, y: y }.to_json
    end

    def end_line(_, player_id)
      return if player_id == id

      @socket << { command: :end_line }.to_json
    end

    def switch_color(_, player_id, color)
      return if player_id == id

      @socket << { command: :switch_color, color: color }.to_json
    end

    def on_message(message)
      case message["command"]
      when "switch_color"
        publish("switch_color", id, message["color"])
      when "start_line", "line_to"
        publish(message["command"], id, message["x"], message["y"])
      when "end_line"
        publish(message["command"], id)
      when "guess"
        @coordinator.async.guess(id, message["word"])
      end
    end
  end

  class PlayerConnection
    include Celluloid

    def initialize(player, socket)
      @player = player
      @socket = socket

      async.listen
    end

    def listen
      loop do
        @player.async.on_message next_message
      end
    ensure
      terminate
    end

    def next_message
      JSON.parse(@socket.read)
    rescue JSON::ParserError
      {}
    end
  end
end

DrawSomething::Endpoint.run
