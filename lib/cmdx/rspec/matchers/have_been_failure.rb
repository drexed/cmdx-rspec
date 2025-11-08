# frozen_string_literal: true

# Matcher to verify that a result represents a failure.
#
# @param data [Hash] Optional hash of additional attributes to match
#   @option data [Symbol] :state Expected state (defaults to CMDx::Result::INTERRUPTED)
#   @option data [Symbol] :status Expected status (defaults to CMDx::Result::FAILED)
#   @option data [Symbol] :outcome Expected outcome (defaults to CMDx::Result::FAILED)
#   @option data [String] :reason Expected reason string
#   @option data [CMDx::FailFault] :cause Expected cause fault
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
      state: CMDx::Result::INTERRUPTED,
      status: CMDx::Result::FAILED,
      outcome: CMDx::Result::FAILED,
      reason: CMDx::Locale.t("cmdx.faults.unspecified"),
      cause: be_a(CMDx::FailFault),
      **data
    )
  end
end
