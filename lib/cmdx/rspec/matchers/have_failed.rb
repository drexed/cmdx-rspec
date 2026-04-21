# frozen_string_literal: true

# Matcher to verify that a result represents a failure.
#
# @param data [Hash] Optional hash of additional attributes to match
#   @option data [String] :state Expected state (defaults to CMDx::Signal::INTERRUPTED)
#   @option data [String] :status Expected status (defaults to CMDx::Signal::FAILED)
#   @option data [String] :reason Expected reason string
#   @option data [Exception] :cause Expected underlying cause
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @raise [ArgumentError] if the actual value is not a CMDx::Result
#
# @example Checking if a result is a failure
#   result = MyCommand.execute
#   expect(result).to have_failed
#
# @example Checking failure with specific reason
#   result = MyCommand.execute
#   expect(result).to have_failed(reason: "Custom error message")
RSpec::Matchers.define :have_failed do |**data|
  description { "have been a failure" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h).to include(
      state: CMDx::Signal::INTERRUPTED,
      status: CMDx::Signal::FAILED,
      **data
    )
  end
end
