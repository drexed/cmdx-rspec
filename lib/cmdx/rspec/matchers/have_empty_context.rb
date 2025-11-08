# frozen_string_literal: true

# Matcher to verify that a context is empty.
#
# @param context [Hash, CMDx::Context, CMDx::Result] The context to check
#   - If Hash, checks the hash directly
#   - If CMDx::Context, converts to hash and checks
#   - If CMDx::Result, extracts context and checks
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @raise [RuntimeError] if the context type is unknown
#
# @example Checking empty context from a hash
#   context = {}
#   expect(context).to have_empty_context
#
# @example Checking empty context from a result
#   result = MyCommand.execute
#   expect(result).to have_empty_context
RSpec::Matchers.define :have_empty_context do
  description { "have an empty context" }

  match(notify_expectation_failures: true) do |context|
    ctx =
      case context
      when Hash then context
      when CMDx::Context then context.to_h
      when CMDx::Result then context.context.to_h
      else raise "unknown context type #{context.class}"
      end

    expect(ctx).to be_empty
  end
end
