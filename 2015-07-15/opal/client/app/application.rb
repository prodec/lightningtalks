require "opal"
require "browser"
require "browser/console"
require "browser/canvas"
require "browser/dom/element"
require "browser/socket"
require "jquery"
require "opal-jquery"
require "observer"

class Application
  def initialize
    canvas = Element["#board"]
    @board = DrawingBoard.new(canvas, ColorSelector::COLORS.first)
    @tool  = DrawingTool.new(canvas, @board)
    @color_selector = ColorSelector.new
    @connection = Connection.new(@tool, @board)

    @color_selector.add_observer(@tool)
    @color_selector.add_observer(@connection)
  end

  def run
  end
end

class Connection
  def initialize(tool, board)
    @board  = board
    @socket = connect
    @tool   = tool

    @tool.add_observer(self)
  end

  def connect
    board = @board

    Browser::Socket.new("ws://localhost:7331") do
      on :open do
        puts "Connected"
      end

      on :message do |e|
        msg = JSON.parse(e.data)
        case msg["command"]
        when "start_line"
          board.start_line(msg["x"], msg["y"])
        when "line_to"
          board.line_to(msg["x"], msg["y"])
        when "switch_color"
          board.switch_color(msg["color"])
        when "end_line"
          board.end_line
        else
          puts msg
        end
      end
    end
  end

  def update(event, *args)
    case event
    when :start_line, :line_to
      @socket.write({ command: event, x: args.first, y: args.last }.to_json)
    when :color_changed
      @socket.write({ command: :switch_color, color: args.first }.to_json)
    when :end_line
      @socket.write({ command: :end_line }.to_json)
    end
  end
end

class ColorSelector
  COLORS = %w(#58595b #ca0231 #963026 #fd001c #fc002a #a24735 #994b3b #905c41 #fe5273 #f87526)

  include Observable

  def initialize
    @container = Element["#color-selector"]
    @colors    = create_selector
    @selected  = @colors.first
  end

  attr_reader :container, :selected

  def create_selector
    COLORS.map do |color|
      ColorBox.new(color, color == COLORS.first).tap do |box|
        container.append(box.el)
        box.add_observer(self)
      end
    end
  end

  def update(_, box)
    return if box == selected

    selected && selected.unselect
    box.select

    @selected = box

    notify_color_changed
  end

  def notify_color_changed
    changed
    notify_observers :color_changed, @selected.color
  end
end

class ColorBox
  include Observable

  def initialize(color, start_selected = false)
    @color    = color
    @selected = start_selected
  end

  attr_reader :color, :selected
  private :selected

  def el
    @el ||= color_box.append(color_display)
  end

  def select
    @selected = true
    el.add_class("selected")
  end

  def unselect
    @selected = false
    el.remove_class("selected")
  end

  private

  def color_display
    Element["<div>"]
      .add_class("color")
      .css("background", color)
  end

  def color_box
    ctx = self

    Element["<div>"]
      .add_class("color-box").tap do |box|
      box.add_class("selected") if selected

      box.on(:click) do
        ctx.changed
        ctx.notify_observers :clicked, self
      end
    end
  end
end

class DrawingTool
  include Observable

  def initialize(canvas, board)
    @canvas = canvas
    @board  = board

    connect_events
  end

  attr_reader :canvas, :board

  def update(event, *args)
    if event == :color_changed
      board.switch_color(args.first)
    end
  end

  def connect_events
    ctx = self

    canvas.on(:mousedown) do |e|
      @drawing = true
      x = e["offsetX"]
      y = e["offsetY"]

      board.start_line(x, y)
      ctx.changed
      ctx.notify_observers(:start_line, x, y)
    end

    canvas.on(:mouseup) do
      board.end_line

      ctx.changed
      ctx.notify_observers :end_line
    end

    canvas.on(:mousemove) do |e|
      board.draw_line(e["offsetX"], e["offsetY"])
      ctx.changed
      ctx.notify_observers :line_to, e["offsetX"], e["offsetY"]
    end
  end
end

class DrawingBoard
  def initialize(canvas, starting_color)
    @canvas_dom = canvas
    @canvas     = Browser::Canvas.new(Browser::DOM::Element.new(canvas_dom.get(0)))
    @drawing    = false
    @color      = starting_color
    @last_pos   = nil

    draw_background
  end

  attr_reader :canvas, :canvas_dom
  attr_accessor :color

  def switch_color(color)
    @color = color
  end

  def line_to(x, y)
    draw_line(x, y)
  end

  def start_line(x, y)
    @last_pos = [x, y]
  end

  def end_line
    @drawing  = false
    @last_pos = nil
  end

  private

  def draw_background
    canvas.style.fill = "#ffffff"
    canvas.clear(0, 0, canvas.width, canvas.height)
    canvas.rect(0, 0, canvas.width, canvas.height)
    canvas.fill
  end

  def draw_line(x, y)
    return if @last_pos.nil?

    canvas.begin
    canvas.style.stroke = color
    canvas.style.line.width = 4
    canvas.line(@last_pos[0], @last_pos[1], x, y)
    canvas.stroke
    canvas.close

    @last_pos = [x, y]
  end
end

Application.new.run
