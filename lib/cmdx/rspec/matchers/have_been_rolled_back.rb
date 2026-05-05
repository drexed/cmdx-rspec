# frozen_string_literal: true

# Matcher to verify that a failing task ran its rollback hook.
#
# @example
#   expect(result).to have_been_rolled_back
RSpec::Matchers.define :have_been_rolled_back do
  description { "have been rolled back" }

  failure_message do |result|
    "expected #{result.inspect} to have been rolled back, but it wasn't"
  end

  failure_message_when_negated do |result|
    "expected #{result.inspect} not to have been rolled back, but it was"
  end

  match do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    result.rolled_back?
  end
end
