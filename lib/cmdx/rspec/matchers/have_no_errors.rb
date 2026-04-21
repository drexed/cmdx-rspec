# frozen_string_literal: true

# Matcher to verify that a {CMDx::Result}, task instance, or {CMDx::Errors}
# is free of errors.
#
# @example
#   expect(result).to have_no_errors
RSpec::Matchers.define :have_no_errors do
  description { "have no errors" }

  failure_message do |actual|
    errors = extract_errors(actual)
    "expected #{actual.inspect} to have no errors, but had #{errors&.to_h.inspect}"
  end

  match do |actual|
    errors = extract_errors(actual)
    next false if errors.nil?

    errors.empty?
  end

  define_method(:extract_errors) do |actual|
    case actual
    when CMDx::Errors then actual
    when CMDx::Result, CMDx::Task then actual.errors
    else actual.respond_to?(:errors) ? actual.errors : nil
    end
  end
end
