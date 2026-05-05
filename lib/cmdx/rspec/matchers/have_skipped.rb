# frozen_string_literal: true

# Asserts a {CMDx::Result} was skipped (`state: interrupted`,
# `status: skipped`). Extra keyword args constrain other `result.to_h`
# fields such as `:reason`, `:cause`, or `:metadata`.
#
# @example
#   expect(result).to have_skipped(reason: "out of stock")
RSpec::Matchers.define :have_skipped do |**data|
  description { "have been skipped" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h).to include(
      state: CMDx::Signal::INTERRUPTED,
      status: CMDx::Signal::SKIPPED,
      **data
    )
  end
end
