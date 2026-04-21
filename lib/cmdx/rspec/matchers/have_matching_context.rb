# frozen_string_literal: true

# Asserts the subject's context includes the supplied keys/values.
# Accepts a `Hash`, {CMDx::Context}, or {CMDx::Result}. With no keyword
# args, delegates to {have_empty_context}.
#
# @example
#   expect(result).to have_matching_context(stored_id: 123)
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
