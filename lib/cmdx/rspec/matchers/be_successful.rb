# frozen_string_literal: true

# Matcher to verify that a result represents a successful execution.
#
# @param data [Hash] Optional hash of additional attributes to match
#   @option data [String] :state Expected state (defaults to CMDx::Signal::COMPLETE)
#   @option data [String] :status Expected status (defaults to CMDx::Signal::SUCCESS)
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @raise [ArgumentError] if the actual value is not a CMDx::Result
#
# @example Checking if a result is successful
#   result = MyCommand.execute
#   expect(result).to be_successful
#
# @example Checking success with additional attributes
#   result = MyCommand.execute
#   expect(result).to be_successful(state: CMDx::Signal::COMPLETE)
RSpec::Matchers.define :be_successful do |**data|
  description { "have been a success" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h).to include(
      state: CMDx::Signal::COMPLETE,
      status: CMDx::Signal::SUCCESS,
      **data
    )
  end
end
