module Ocd
end

require_relative "ocd/application"
require_relative "ocd/display"
require_relative "ocd/input"
require_relative "ocd/command_line"

Ocd::Application.run
