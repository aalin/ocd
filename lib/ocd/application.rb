require 'shellwords'

class Ocd::Application
  def self.run(commands_file)
    Ocd::Display.open do |display|
      app = self.new(display)

      begin
        last_update = Time.now

        while app.running?
          now = Time.now
          app.update(now - last_update)
          app.draw
          sleep 0.05
          last_update = now
        end
      ensure
        app.finish
        write_commands(commands_file, app.commands) if commands_file
        puts app.commands
      end
    end
  end

  def self.write_commands(file, commands)
    File.open(file, 'w') do |f|
      commands.each do |command|
        f.puts command
      end
    end
  end

  attr_reader :commands

  def initialize(display)
    @display = display
    @input = Ocd::Input.new
    @browser = Ocd::Browser.new(self)

    @commands = []

    @running = true

    @states = []
  end

  def finish
    @display.clear_screen
    @display.show_cursor
  end

  def running?
    @running
  end

  def alert(message)
    push_state Ocd::Alert.new(self, message)
  end

  def stop
    # cd to the current directory!
    @commands.unshift(["cd", @browser.absolute_path].shelljoin)
    @running = false
  end

  def pop_state
    @states.pop
  end

  def push_state(state)
    @states.push(state)
  end

  def update(s)
    @display.update

    @input.update.each do |char|
      current_state.add_char(char)
    end

    @browser.update(self, s)

    @states.each do |state|
      state.update(self, s)
    end
  end

  def draw
    @display.hide_cursor

    @display.draw
    @browser.draw(@display)

    @states.each do |state|
      state.draw(@display)
    end

    @display.flush($stdout)
  end

  private

  def current_state
    @states.last || @browser
  end
end
