# frozen_string_literal: true

require "cmdx"
require "rspec"

require_relative "rspec/helpers"

require_relative "rspec/matchers/be_deprecated"
require_relative "rspec/matchers/be_successful"
require_relative "rspec/matchers/have_skipped"
require_relative "rspec/matchers/have_failed"
require_relative "rspec/matchers/have_empty_context"
require_relative "rspec/matchers/have_matching_context"
require_relative "rspec/matchers/have_empty_metadata"
require_relative "rspec/matchers/have_matching_metadata"
