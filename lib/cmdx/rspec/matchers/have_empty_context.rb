# frozen_string_literal: true

# Asserts the subject's context hash is empty. Accepts a `Hash`,
# {CMDx::Context}, or {CMDx::Result} (in which case `result.context` is
# inspected). Raises if the subject is none of those.
#
# @example
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
