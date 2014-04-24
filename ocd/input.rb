require 'io/console'

class Ocd::Input
  def initialize
    @buffer = []
    @buffer_mutex = Mutex.new

    Thread.new do
      loop do
        char = $stdin.getch

        @buffer_mutex.synchronize do
          @buffer << char
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
end
