# frozen_string_literal: true

# Matcher to verify that a result represents a successful execution.
#
# @param data [Hash] Optional hash of additional attributes to match
#   @option data [Symbol] :state Expected state (defaults to CMDx::Result::COMPLETE)
#   @option data [Symbol] :status Expected status (defaults to CMDx::Result::SUCCESS)
#   @option data [Symbol] :outcome Expected outcome (defaults to CMDx::Result::SUCCESS)
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @raise [ArgumentError] if the actual value is not a CMDx::Result
#
# @example Checking if a result is successful
#   result = MyCommand.execute
#   expect(result).to have_been_success
#
# @example Checking success with additional attributes
#   result = MyCommand.execute
#   expect(result).to have_been_success(state: CMDx::Result::COMPLETE)
RSpec::Matchers.define :have_been_success do |**data|
  description { "have been a success" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h).to include(
      state: CMDx::Result::COMPLETE,
      status: CMDx::Result::SUCCESS,
      outcome: CMDx::Result::SUCCESS,
      **data
    )
  end
end
