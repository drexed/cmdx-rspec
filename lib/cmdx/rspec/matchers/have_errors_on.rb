# frozen_string_literal: true

# Matcher to verify that a {CMDx::Result}, task instance, or {CMDx::Errors}
# carries at least one error under +key+. Optional +messages+ further
# constrain the matcher to specific error strings.
#
# @example Any error on :email
#   expect(result).to have_errors_on(:email)
#
# @example Specific message
#   expect(result).to have_errors_on(:email, "is required")
#
# @example Multiple messages (all must be present)
#   expect(task).to have_errors_on(:email, "is required", "is invalid")
RSpec::Matchers.define :have_errors_on do |key, *messages|
  description do
    if messages.empty?
      "have errors on #{key.inspect}"
    else
      "have errors on #{key.inspect} matching #{messages.inspect}"
    end
  end

  failure_message do |actual|
    errors = extract_errors(actual)
    if errors.nil?
      "expected #{actual.inspect} to expose an Errors collection"
    elsif !errors.key?(key)
      "expected errors on #{key.inspect}, but only had: #{errors.keys.inspect}"
    else
      "expected errors on #{key.inspect} to include #{messages.inspect}, but had #{errors[key].inspect}"
    end
  end

  match do |actual|
    errors = extract_errors(actual)
    next false if errors.nil?
    next false unless errors.key?(key)

    messages.all? { |m| errors.added?(key, m) }
  end

  define_method(:extract_errors) do |actual|
    case actual
    when CMDx::Errors then actual
    when CMDx::Result, CMDx::Task then actual.errors
    else actual.respond_to?(:errors) ? actual.errors : nil
    end
  end
end
