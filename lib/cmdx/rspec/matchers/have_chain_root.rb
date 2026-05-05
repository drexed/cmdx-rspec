# frozen_string_literal: true

# Matcher to verify that a {CMDx::Chain}'s root is a {CMDx::Result} for
# the given task class. Accepts either a Chain or a Result.
#
# @example
#   expect(result).to have_chain_root(MyWorkflow)
RSpec::Matchers.define :have_chain_root do |task_class|
  description { "have chain root #{task_class}" }

  failure_message do |actual|
    chain = extract_chain(actual)
    "expected chain root to be #{task_class}, but was #{chain&.root&.task.inspect}"
  end

  match do |actual|
    chain = extract_chain(actual)
    next false if chain.nil?
    next false if chain.root.nil?

    chain.root.task <= task_class
  end

  define_method(:extract_chain) do |actual|
    case actual
    when CMDx::Chain  then actual
    when CMDx::Result then actual.chain
    end
  end
end
