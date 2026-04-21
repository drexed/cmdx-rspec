# frozen_string_literal: true

# Matcher to verify that a task class is deprecated.
#
# @param expected_behavior [Symbol, Proc, #call, nil] Optional behavior to check
#   - `:warn` - checks that deprecation is configured to warn
#   - `:log` - checks that deprecation is configured to log
#   - `:error` - checks that deprecation is configured to raise
#   - `Symbol` / `Proc` / callable - checks for exact equality with the configured value
#   - `nil` (default) - just checks that the task is deprecated
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @example Checking if a task is deprecated
#   expect(MyCommand).to be_deprecated
#
# @example Checking deprecated with error behavior
#   expect(MyCommand).to be_deprecated(:error)
#   expect(MyCommand).to be_deprecated.with_error
#
# @example Checking deprecated with warning behavior
#   expect(MyCommand).to be_deprecated(:warn)
#   expect(MyCommand).to be_deprecated.with_warning
#
# @example Checking deprecated with logging behavior
#   expect(MyCommand).to be_deprecated(:log)
#   expect(MyCommand).to be_deprecated.with_logging
#
# @example Using a custom behavior
#   expect(MyCommand).to be_deprecated.with_behavior(:notify_sentry)
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
