# frozen_string_literal: true

# Matcher to verify that a task class declares an output named +name+.
# Optional keyword arguments are matched against the output's serialized
# {CMDx::Output#to_h} (partial match — only provided keys are checked).
#
# @example Existence check
#   expect(MyCommand).to have_output(:total)
#
# @example Required output
#   expect(MyCommand).to have_output(:total, required: true)
RSpec::Matchers.define :have_output do |name, **expected|
  description do
    expected.empty? ? "have output #{name.inspect}" : "have output #{name.inspect} matching #{expected.inspect}"
  end

  failure_message do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    output = target.outputs.registry[name.to_sym]
    if output.nil?
      "expected #{target} to declare output #{name.inspect}, but registry has #{target.outputs.registry.keys.inspect}"
    else
      "expected #{target}'s output #{name.inspect} to match #{expected.inspect}, but it was #{output.to_h.inspect}"
    end
  end

  match do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    next false unless target.respond_to?(:outputs)

    output = target.outputs.registry[name.to_sym]
    next false if output.nil?
    next true if expected.empty?

    schema = output.to_h
    expected.all? { |k, v| values_match?(v, schema[k]) }
  end
end
