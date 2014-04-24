require 'stringio'

class Ocd::Display
  module ANSI
    HIDE_CURSOR = "\e[?25i"
    SHOW_CURSOR = "\e[?25h"
    COLOR_FG_256 = "\e[38;5;%dm"
    COLOR_BG_256 = "\e[48;5;%dm"
    SET_CURSOR_POSITION = "\e[%2$d;%1$dH"
    CLEAR_LINE = "\e[K"
    CLEAR_SCREEN = "\e[H\e[J"
    BEGINNING_OF_LINE = "\e[G"
    CLEAR_AND_MOVE_TO_HOME = "\e[2J"
    ALTERNATE_SCREEN_BUFFER = "\e[?1047h"
    RESTORE_SCREEN_BUFFER = "\e[?1047l"
  end

  attr_reader :width
  attr_reader :height

  def self.open(out = $stdout)
    begin
      print(ANSI::ALTERNATE_SCREEN_BUFFER)
      yield new(out)
    ensure
      print(ANSI::BEGINNING_OF_LINE + ANSI::RESTORE_SCREEN_BUFFER)
    end
  end

  def initialize(output)
    @out = $stdout
    update_width_and_height
    @buffer = StringIO.new
    @cursor_visible = true
    @show_cursor = true
    @color_stack = []

    @current_fg = nil
    @current_bg = nil
    print_raw(ANSI::CLEAR_AND_MOVE_TO_HOME)
  end

  def show_cursor
    @show_cursor = true
  end

  def hide_cursor
    @show_cursor = false
  end

  def update
    update_width_and_height
  end

  def draw
    if @width_and_height_updated
      clear_screen
    end
  end

  def set_cursor_position(x, y)
    @next_position = [x, y]
  end

  def color(fg, bg = nil)
    @color_stack.push([fg, bg])
    yield
    @color_stack.pop
  end

  def print(str)
    update_cursor_visibility
    update_cursor_position
    update_colors

    print_raw(str.gsub("\e", "\\e")) # Escape escape-sequences... :)

    @next_position = nil
    @cursor_position = nil
  end

  def print_raw(str)
    @buffer.write(str)
    @line_cleared = false
  end

  def flush(output)
    update_cursor_visibility
    update_cursor_position
    @buffer.rewind

    unless @buffer.eof?
      data = @buffer.read
      log data.inspect
      output.write(data)
    end

    @buffer = StringIO.new
  end

  def clear_line
    update_cursor_position
    return if @line_cleared
    print_raw(ANSI::CLEAR_LINE)
    @line_cleared = true
  end

  def clear_screen
    @line_cleared = false
    print_raw(ANSI::CLEAR_SCREEN)
  end

  private

  def update_cursor_position
    unless @cursor_position == @next_position
      @cursor_position = @next_position
      print_raw(ANSI::SET_CURSOR_POSITION % @cursor_position)
    end
  end

  def update_cursor_visibility
    if @cursor_visible
      unless @show_cursor
        log "hide cursor"
        print_raw(ANSI::HIDE_CURSOR)
        @cursor_visible = false
      end
    else # cursor not visible
      if @show_cursor
        log "display cursor"
        print_raw(ANSI::SHOW_CURSOR)
        @cursor_visible = true
      end
    end
  end

  def update_colors
    fg, bg = @color_stack.last

    if fg && fg != @current_fg
      @current_fg = fg
      print_raw(ANSI::COLOR_FG_256 % fg)
    elsif !fg && @current_fg
      print_raw(ANSI::COLOR_FG_256 % 15)
      @current_fg = nil
    end

    if bg && bg != @current_bg
      @current_bg = bg
      print_raw(ANSI::COLOR_BG_256 % bg)
    elsif !bg && @current_bg
      print_raw(ANSI::COLOR_BG_256 % 0)
      @current_bg = nil
    end
  end

  def update_width_and_height
    new_height, new_width = $stdin.winsize

    equal_height = @height == new_height
    equal_width = @width == new_width

    if equal_height && equal_width
      @width_and_height_updated = false
    else
      @height = new_height
      @width = new_width
      @width_and_height_updated = true
    end
  end

  def log(message)
    time_str = Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")
    str = format("%s: %s\r\n", time_str, message)
    File.write("display.log", str, mode: "a")
  end
end
