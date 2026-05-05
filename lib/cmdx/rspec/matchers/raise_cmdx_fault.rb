# frozen_string_literal: true

# Matcher to verify that a block raises a {CMDx::Fault}, optionally
# constraining which task originated the failure, the failure reason, and
# the underlying cause.
#
# @example Any CMDx fault
#   expect { MyCommand.execute! }.to raise_cmdx_fault
#
# @example From a specific task class (matches `fault.task`, the leaf failure)
#   expect { MyCommand.execute! }.to raise_cmdx_fault(MyCommand)
#
# @example With a specific reason
#   expect { MyCommand.execute! }.to raise_cmdx_fault.with_reason("invalid")
#
# @example With a regex reason and a specific underlying cause
#   expect { MyCommand.execute! }
#     .to raise_cmdx_fault(MyCommand).with_reason(/invalid/).with_cause(MyError)
RSpec::Matchers.define :raise_cmdx_fault do |expected_task = nil|
  description do
    parts = ["raise CMDx::Fault"]
    parts << "from #{expected_task}" if expected_task
    parts << "with reason #{@expected_reason.inspect}" if defined?(@expected_reason)
    parts << "with cause #{@expected_cause.inspect}" if defined?(@expected_cause)
    parts.join(" ")
  end

  supports_block_expectations

  match do |block|
    raise ArgumentError, "block required" unless block.respond_to?(:call)

    @actual_fault = nil
    begin
      block.call
    rescue CMDx::Fault => e
      @actual_fault = e
    end

    next false if @actual_fault.nil?
    next false if expected_task && !(@actual_fault.task <= expected_task) # rubocop:disable Style/InverseMethods
    next false if defined?(@expected_reason) && !reason_matches?(@actual_fault.result.reason)
    next false if defined?(@expected_cause) && !cause_matches?(@actual_fault.result.cause)

    true
  end

  failure_message do
    if @actual_fault.nil?
      "expected block to raise CMDx::Fault, but nothing was raised"
    else
      "expected #{@actual_fault.inspect} (task: #{@actual_fault.task}, reason: " \
        "#{@actual_fault.result.reason.inspect}, cause: #{@actual_fault.result.cause.inspect}) " \
        "to satisfy the matcher"
    end
  end

  chain(:with_reason) { |reason| @expected_reason = reason }
  chain(:with_cause)  { |cause|  @expected_cause  = cause }

  define_method(:reason_matches?) do |actual|
    case @expected_reason
    when Regexp then @expected_reason.match?(actual.to_s)
    else @expected_reason == actual
    end
  end

  define_method(:cause_matches?) do |actual|
    case @expected_cause
    when Class then actual.is_a?(@expected_cause)
    else values_match?(@expected_cause, actual)
    end
  end
end
