# frozen_string_literal: true

# Matcher to verify that a context matches the given data.
#
# @param data [Hash] Optional hash of key-value pairs to match in the context
#   If empty, delegates to {have_empty_context}
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
# @example Checking context matches specific values
#   result = MyCommand.execute(user_id: 123, role: "admin")
#   expect(result).to have_matching_context(user_id: 123, role: "admin")
#
# @example Checking empty context
#   result = MyCommand.execute
#   expect(result).to have_matching_context
RSpec::Matchers.define :have_matching_context do |**data|
  description { "have matching context" }

  match(notify_expectation_failures: true) do |context|
    ctx =
      case context
      when Hash then context
      when CMDx::Context then context.to_h
      when CMDx::Result then context.context.to_h
      else raise "unknown context type #{context.class}"
      end

    if data.empty?
      expect(ctx).to have_empty_context
    else
      expect(ctx).to include(**data)
    end
  end
end
