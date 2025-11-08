# frozen_string_literal: true

require "cmdx"
require "rspec"

require_relative "rspec/helpers/stubs"

require_relative "rspec/matchers/be_deprecated"
require_relative "rspec/matchers/have_been_failure"
require_relative "rspec/matchers/have_been_skipped"
require_relative "rspec/matchers/have_been_success"
require_relative "rspec/matchers/have_empty_context"
require_relative "rspec/matchers/have_matching_context"
require_relative "rspec/matchers/have_empty_metadata"
require_relative "rspec/matchers/have_matching_metadata"
