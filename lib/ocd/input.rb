require 'io/console'

class Ocd::Input
  class Character
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      if special?
        "<#{ @value.inspect }>"
      else
        @value.to_s
      end
    end

    def special?
      @value.is_a?(Symbol)
    end
  end

  ESCAPE = "\e"
  BRACKET = "["

  def initialize
    @buffer = []
    @buffer_mutex = Mutex.new

    @in_escape = false
    @in_bracket = false

    Thread.new do
      loop do
        char = $stdin.getch

        @buffer_mutex.synchronize do
          log("Got char: #{ char.inspect }")

          unless handle_escape_sequence(char)
            if char == ESCAPE
              @in_escape = true
            else
              @buffer << Character.new(char)
            end
          end
        end
      end
    end
  end

  def update
    buffer = nil

    @buffer_mutex.synchronize do
      buffer = @buffer.dup
      @buffer.clear
    end

    buffer
  end

  private

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
      log("Escape sequence: \\e[#{ char }")
      case char
      when "A" # UP
        @buffer << Character.new(:key_up)
        return true
      when "B" # DOWN
        @buffer << Character.new(:key_down)
        return true
      when "D" # LEFT
        @buffer << Character.new(:key_left)
        return true
      when "C" # RIGHT
        @buffer << Character.new(:key_right)
        return true
      end
    end

    @in_escape = false
    @in_bracket = false

    false
  end

  def log(message)
    return
    time_str = Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")
    str = format("%s: %s\r\n", time_str, message)
    File.write("input.log", str, mode: "a")
  end
end
