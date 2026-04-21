# frozen_string_literal: true

# Matcher to verify that a task class declares an input named +name+.
# Optional keyword arguments are matched against the input's serialized
# {CMDx::Input#to_h} (partial match — only provided keys are checked).
#
# @example Existence check
#   expect(MyCommand).to have_input(:user_id)
#
# @example Required input
#   expect(MyCommand).to have_input(:user_id, required: true)
#
# @example Type / coercion check (matches against the +options+ hash)
#   expect(MyCommand).to have_input(:user_id, options: hash_including(coerce: :integer))
RSpec::Matchers.define :have_input do |name, **expected|
  description do
    expected.empty? ? "have input #{name.inspect}" : "have input #{name.inspect} matching #{expected.inspect}"
  end

  failure_message do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    input = target.inputs.registry[name.to_sym]
    if input.nil?
      "expected #{target} to declare input #{name.inspect}, but registry has #{target.inputs.registry.keys.inspect}"
    else
      "expected #{target}'s input #{name.inspect} to match #{expected.inspect}, but it was #{input.to_h.inspect}"
    end
  end

  match do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    next false unless target.respond_to?(:inputs)

    input = target.inputs.registry[name.to_sym]
    next false if input.nil?
    next true if expected.empty?

    schema = input.to_h
    expected.all? { |k, v| values_match?(v, schema[k]) }
  end
end
