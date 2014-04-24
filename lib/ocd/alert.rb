class Ocd::Alert
  def initialize(app, message)
    @app = app
    @message = message
    @display_size_cache = Ocd::ValueCache.new
  end

  def add_char(char)
    @app.pop_state # Just get out of this!
  end

  def update(app, s)
  end

  def draw(display)
    @display_size_cache.update([display.width, display.height])

    if @display_size_cache.updated?
      display.hide_cursor
      display.set_cursor_position(0, 0)
      display.color(15, 160) { display.print(@message.center(display.width)) }
    end
  end
end
