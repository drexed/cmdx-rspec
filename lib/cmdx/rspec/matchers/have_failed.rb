# frozen_string_literal: true

# Asserts a {CMDx::Result} failed (`state: interrupted`,
# `status: failed`). Extra keyword args constrain other `result.to_h`
# fields such as `:reason`, `:cause`, or `:metadata`.
#
# @example
#   expect(result).to have_failed(cause: be_a(NoMethodError))
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
