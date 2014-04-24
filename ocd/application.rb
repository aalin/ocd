class Ocd::Application
  def self.run
    app = self.new

    loop do
      app.update
      app.draw
      sleep 0.05
    end
  end

  def initialize
    @input = Ocd::Input.new
    @display = Ocd::Display.new
    @command_line = Ocd::CommandLine.new
  end

  def update
    @display.update

    @input.update.each do |char|
      @command_line.add_char(char)
    end
  end

  def draw
    @display.set_cursor_position(1, 1)
    @display.clear_line
    print @command_line.buffer.inspect

    @display.set_cursor_position(1, 2)
    @display.clear_line
    print @command_line.text

    @command_line.history.each_with_index do |line, i|
      @display.set_cursor_position(1, 3 + i)
      @display.clear_line
      print line.inspect
    end

    @display.set_cursor_position(1, @display.height)
    @display.clear_line
    print "history_index: #{ @command_line.history_index }"
  end

  private

  def pwd
    Dir.pwd
  end
end
