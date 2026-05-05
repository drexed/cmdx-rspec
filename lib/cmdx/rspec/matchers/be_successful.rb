# frozen_string_literal: true

# Asserts a {CMDx::Result} represents a successful execution
# (`state: complete`, `status: success`). Additional keyword args are
# merged into a `result.to_h` inclusion check, so any Result field can be
# constrained inline (e.g. `be_successful(metadata: { id: 1 })`).
#
# @example
#   expect(SomeTask.execute).to be_successful
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
