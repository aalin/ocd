require 'shellwords'

class Ocd::OpenFileDialog
  class Command
    attr_reader :name

    def initialize(name, parts)
      @name = name
      @parts = parts
    end

    def shell_string(filename)
      @parts.map { |part|
        if part == :file
          filename
        else
          part
        end
      }.shelljoin
    end
  end

  COMMANDS = [
    Command.new("vim", ["vim", :file]),
    Command.new("cd", ["cd", :file]),
  ]

  def initialize(app, filename)
    @app = app
    @filename = filename
  end

  def add_char(char)
    case char.value
    when "\u0003"
      raise Interrupt
    when "\e"
      @app.pop_state
    when /^\d$/
      index = char.value.to_i - 1

      if index >= 0 && command = COMMANDS[index]
        @app.commands.push command.shell_string(@filename)
        @app.stop
      else
        @app.alert("out of bounds")
      end
    end
  end

  def update(app, s)
  end

  def draw(display)
    display.hide_cursor

    display.set_cursor_position(20, 10)
    display.color(0, 237) { display.print " " * 50 }
    display.set_cursor_position(20, 11)
    display.color(0, 237) { display.print " " * 50 }
    display.set_cursor_position(22, 11)
    display.color(0, 237) { display.print "Open #{ @filename }" }
    display.set_cursor_position(20, 12)
    display.color(0, 237) { display.print " " * 50 }


    COMMANDS.each.with_index(1) do |command, i|
      display.set_cursor_position(20, 12 + i)
      display.color(0, 237) { display.print " " * 50 }
      display.set_cursor_position(22, 12 + i)
      display.color(255, 237) { display.print "[#{ i }] #{ command.name }" }
    end
  end
end
