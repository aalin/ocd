class Ocd::Display
  attr_reader :width
  attr_reader :height

  def initialize
    update_width_and_height
    print "\e[2J"
  end

  def update
    update_width_and_height
  end

  def set_cursor_position(x, y)
    print "\e[#{y};#{x}H"
  end

  def clear_line
    print "\e[K"
  end

  private

  def update_width_and_height
    @height, @width = $stdin.winsize
  end
end
