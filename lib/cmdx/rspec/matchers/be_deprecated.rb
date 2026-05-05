# frozen_string_literal: true

# Asserts a Task class (or instance) is marked deprecated via CMDx's
# `deprecation` declaration. Optionally constrains the deprecation
# behavior — pass it positionally, via `.with_behavior(:warn)`, or use
# the convenience chains `.with_warning`, `.with_logging`, `.with_error`.
#
# @example
#   expect(SomeTask).to be_deprecated.with_warning
RSpec::Matchers.define :be_deprecated do |expected_behavior = nil|
  description do
    if (behavior = @expected_behavior || expected_behavior)
      "be deprecated with behavior #{behavior}"
    else
      "be deprecated"
    end
  end

  failure_message do |actual|
    if (behavior = @expected_behavior || expected_behavior)
      "expected #{actual} to be deprecated with behavior #{behavior}, but it wasn't"
    else
      "expected #{actual} to be deprecated, but it wasn't"
    end
  end

  failure_message_when_negated do |actual|
    if (behavior = @expected_behavior || expected_behavior)
      "expected #{actual} not to be deprecated with behavior #{behavior}, but it was"
    else
      "expected #{actual} not to be deprecated, but it was"
    end
  end

  match do |actual|
    target      = actual.is_a?(Class) ? actual : actual.class
    deprecation = target.respond_to?(:deprecation) ? target.deprecation : nil
    next false unless deprecation

    behavior = @expected_behavior || expected_behavior
    next true unless behavior

    deprecation.instance_variable_get(:@value) == behavior
  end

  chain(:with_warning) { @expected_behavior = :warn }
  chain(:with_logging) { @expected_behavior = :log }
  chain(:with_error)   { @expected_behavior = :error }
  chain(:with_behavior) { |behavior| @expected_behavior = behavior }
end
