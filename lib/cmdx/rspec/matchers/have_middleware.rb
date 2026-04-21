# frozen_string_literal: true

# Matcher to verify that a task class registered +middleware+. When given
# a class, matches by `is_a?`; otherwise by `==` (works for module-level
# callables like `MyMiddleware` referenced by name).
#
# @example
#   expect(MyCommand).to have_middleware(LoggingMiddleware)
RSpec::Matchers.define :have_middleware do |middleware|
  description { "have middleware #{middleware.inspect}" }

  failure_message do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    "expected #{target} to register middleware #{middleware.inspect}, but had #{target.middlewares.registry.inspect}"
  end

  match do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    next false unless target.respond_to?(:middlewares)

    target.middlewares.registry.any? do |m|
      case middleware
      when Class then m.is_a?(middleware) || m == middleware
      else m == middleware
      end
    end
  end
end
