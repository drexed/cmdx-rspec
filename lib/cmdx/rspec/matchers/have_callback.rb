# frozen_string_literal: true

# Matcher to verify that a task class registered a callback for +event+.
# Optional +callable+ further constrains the matcher; matched by `==`
# (Symbol method names, Proc/Object identity), or by class membership
# when given a class.
#
# @example Any callback for an event
#   expect(MyCommand).to have_callback(:before_execution)
#
# @example A specific Symbol callback
#   expect(MyCommand).to have_callback(:before_execution, :authenticate!)
#
# @example A callable instance class
#   expect(MyCommand).to have_callback(:on_failed, AlertOnFailure)
RSpec::Matchers.define :have_callback do |event, callable = nil|
  description do
    callable.nil? ? "have callback for #{event.inspect}" : "have callback #{callable.inspect} for #{event.inspect}"
  end

  failure_message do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    entries = target.callbacks.registry[event] || []
    if entries.empty?
      "expected #{target} to register a callback for #{event.inspect}, but none were registered"
    else
      "expected #{target} to register #{callable.inspect} for #{event.inspect}, but had #{entries.map(&:first).inspect}"
    end
  end

  match do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    next false unless target.respond_to?(:callbacks)

    entries = target.callbacks.registry[event]
    next false if entries.nil? || entries.empty?
    next true if callable.nil?

    entries.any? do |cb, _opts|
      case callable
      when Class then cb.is_a?(callable)
      else cb == callable
      end
    end
  end
end
