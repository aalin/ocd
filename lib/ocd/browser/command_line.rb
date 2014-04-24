class Ocd::Browser::CommandLine
  # http://en.wikipedia.org/wiki/C0_and_C1_control_codes#C0_.28ASCII_and_derivatives.29
  CTRL_C = "\u0003"
  CTRL_D = "\u0004"
  CTRL_X = "\u0018"
  BACKSPACE = "\u007f"
  RETURN = "\r"
  TAB = "\t"

  attr_reader :buffer

  def initialize
    $stdin.echo = false
    reset_buffer!
    @cache = Ocd::ValueCache.new
  end

  def append(text)
    @buffer.insert(cursor_position, text)
    @cursor_position += text.length
  end

  def add_char(char, callback)
    handle_char(char, callback)
  end

  def text
    @buffer
  end

  def cursor_offset
    [
      [@buffer.length - @cursor_position, 0].max,
      @buffer.length
    ].min
  end

  def reset_buffer!
    @buffer = ""
    @cursor_position = 0
  end

  def update(browser)
    @cache.update("#{ ENV['HOST'] } #{ browser.absolute_path }> " + @buffer)
  end

  def draw(display, y)
    if @cache.updated?
      display.set_cursor_position(1, y)
      display.clear_line
      display.print @cache.value
    end

    display.show_cursor
    display.set_cursor_position(1 + @cache.value.length - cursor_offset, y)
  end

  private

  def handle_char(char, callback)
    case char.value
    when CTRL_C
      raise Interrupt
    when BACKSPACE
      @cursor_position -= 1
      @buffer.slice!(cursor_position)
    when CTRL_D
      reset_buffer! if callback.handle_input_eof
    when TAB
      reset_buffer! if callback.handle_input_tab
    when RETURN
      reset_buffer! if callback.handle_input_return
    when :key_left
      @cursor_position -= 1
    when :key_right
      @cursor_position += 1
    when :key_up
      callback.scroll_up
    when :key_down
      callback.scroll_down
    else
      unless char.special?
        append(char.to_s)
      end
    end
  end

  def cursor_position
    @cursor_position = [0, @cursor_position].max
    @cursor_position = [@buffer.length, @cursor_position].min
  end
end
