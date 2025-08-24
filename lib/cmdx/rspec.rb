# frozen_string_literal: true

require "cmdx"
require "rspec"
require "zeitwerk"

# Set up Zeitwerk loader for the CMDx gem
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("cmdx" => "CMDx")
loader.setup
