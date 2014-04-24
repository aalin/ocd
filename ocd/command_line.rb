class Ocd::CommandLine
  # http://en.wikipedia.org/wiki/C0_and_C1_control_codes#C0_.28ASCII_and_derivatives.29
  CTRL_C = "\u0003"
  CTRL_X = "\u0018"
  BACKSPACE = "\u007f"
  ESCAPE = "\e"
  BRACKET = "["
  RETURN = "\r"

  attr_reader :buffer

  def initialize
    $stdin.echo = false

    reset_buffer!

    @in_escape = false
    @in_bracket = false
    @cursor_position = 0
    @history_index = 0
    @history = []
  end

  def add_char(char)
    handle_char(char)
  end

  def text
    @buffer.join
  end

  def history
    @history.map(&:join)
  end

  attr_reader :history_index

  private

  def reset_buffer!
    @buffer = []
  end

  def handle_char(char)
    return if handle_escape_sequence(char)

    case char
    when CTRL_C
      raise Interrupt
    when ESCAPE
      @in_escape = true
    when BACKSPACE
      @buffer.pop
    when RETURN
      @history.push(@buffer)
      reset_buffer!
    else
      @buffer << char
    end
  end

  def handle_escape_sequence(char)
    case char
    when ESCAPE
      @in_escape = true
      return true
    when BRACKET
      @in_bracket = @in_escape
      return true
    end

    if @in_escape && @in_bracket
      case char
      when "A" # UP
        change_history_index(1)
        return true
      when "B" # DOWN
        change_history_index(-1)
        return true
      when "D" # LEFT
        return true
      when "C" # RIGHT
        return true
      end
    end

    @in_escape = false
    @in_bracket = false

    false
  end

  def change_history_index(value)
    @history_index += value

    @history_index = [@history_index, @history.size].min

    if @history_index <= 0
      reset_buffer!
      @history_index = 0
      return
    end

    @buffer = @history[-@history_index] || reset_buffer!
  end
end
