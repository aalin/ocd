#!/usr/bin/env ruby

require_relative "../lib/ocd"

begin
  commands_file = ARGV.first
  Ocd::Application.run(commands_file)
rescue Interrupt => e
  exit 1
end

exit 0
