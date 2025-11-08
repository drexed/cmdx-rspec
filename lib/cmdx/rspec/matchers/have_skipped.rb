# frozen_string_literal: true

# Matcher to verify that a result represents a skipped execution.
#
# @param data [Hash] Optional hash of additional attributes to match
#   @option data [Symbol] :state Expected state (defaults to CMDx::Result::INTERRUPTED)
#   @option data [Symbol] :status Expected status (defaults to CMDx::Result::SKIPPED)
#   @option data [Symbol] :outcome Expected outcome (defaults to CMDx::Result::SKIPPED)
#   @option data [String] :reason Expected reason string
#   @option data [CMDx::SkipFault] :cause Expected cause fault
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @raise [ArgumentError] if the actual value is not a CMDx::Result
#
# @example Checking if a result is skipped
#   result = MyCommand.execute
#   expect(result).to have_skipped
#
# @example Checking skipped with specific reason
#   result = MyCommand.execute
#   expect(result).to have_skipped(reason: "Skipped for testing")
RSpec::Matchers.define :have_skipped do |**data|
  description { "have been skipped" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h).to include(
      state: CMDx::Result::INTERRUPTED,
      status: CMDx::Result::SKIPPED,
      outcome: CMDx::Result::SKIPPED,
      reason: CMDx::Locale.t("cmdx.faults.unspecified"),
      cause: be_a(CMDx::SkipFault),
      **data
    )
  end
end
