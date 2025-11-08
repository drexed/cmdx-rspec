# frozen_string_literal: true

# Matcher to verify that a command is deprecated.
#
# @param expected_behavior [Symbol, String, true, false, nil] Optional behavior to check
#   - `:warn` or `/warn/` - checks if deprecation includes warning
#   - `:log` or `/log/` - checks if deprecation includes logging
#   - `:raise` or `/raise/` or `true` - checks if deprecation raises or is truthy
#   - `:none` or `false` or `nil` - checks if deprecation is false or nil
#   - Any other value - checks for exact match
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @example Checking if a command is deprecated
#   expect(MyCommand).to be_deprecated
#
# @example Checking deprecated with raise behavior
#   expect(MyCommand).to be_deprecated(:raise)
#   expect(MyCommand).to be_deprecated.with_raise
#
# @example Checking deprecated with warning behavior
#   expect(MyCommand).to be_deprecated(:warn)
#   expect(MyCommand).to be_deprecated.with_warning
#
# @example Checking deprecated with logging behavior
#   expect(MyCommand).to be_deprecated(:log)
#   expect(MyCommand).to be_deprecated.with_logging
#
# @example Using chainable matchers
#   expect(MyCommand).to be_deprecated.with_behavior(:custom)
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
    # Handle both class and instance
    target = actual.is_a?(Class) ? actual : actual.class

    # Check if deprecate setting exists and is truthy
    deprecate_setting = target.settings[:deprecate]
    return false unless deprecate_setting

    # If no specific behavior expected, just check if deprecated
    behavior_to_check = @expected_behavior || expected_behavior
    return true unless behavior_to_check

    # Check specific behavior
    case behavior_to_check
    when :warn, /warn/
      deprecate_setting.to_s.include?("warn")
    when :log, /log/
      deprecate_setting.to_s.include?("log")
    when :raise, /raise/, true
      deprecate_setting == true || deprecate_setting.to_s.include?("raise")
    when :none, false, nil
      !deprecate_setting || deprecate_setting == false
    else
      deprecate_setting == behavior_to_check
    end
  end

  # Chainable matchers for specific behaviors
  chain(:with_raise) { @expected_behavior = :raise }
  chain(:with_logging) { @expected_behavior = :log }
  chain(:with_warning) { @expected_behavior = :warn }
  chain(:with_behavior) { |behavior| @expected_behavior = behavior }
end
