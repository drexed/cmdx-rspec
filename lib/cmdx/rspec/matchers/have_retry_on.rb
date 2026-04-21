# frozen_string_literal: true

# Matcher to verify that a task class is configured to retry on +exception+.
# Optional keyword arguments check the {CMDx::Retry} configuration values
# (`:limit`, `:delay`, `:max_delay`, `:jitter`).
#
# @example
#   expect(MyCommand).to have_retry_on(Net::OpenTimeout)
#   expect(MyCommand).to have_retry_on(Net::OpenTimeout, limit: 5, jitter: :exponential)
RSpec::Matchers.define :have_retry_on do |exception, **expected|
  description do
    expected.empty? ? "have retry on #{exception}" : "have retry on #{exception} matching #{expected.inspect}"
  end

  failure_message do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    retry_cfg = target.retry_on
    if retry_cfg.exceptions.none?(exception)
      "expected #{target} to retry on #{exception}, but only retries on #{retry_cfg.exceptions.inspect}"
    else
      mismatched = expected.reject { |k, v| retry_cfg.public_send(k) == v }
      "expected #{target}'s retry_on to match #{expected.inspect}, but mismatched: #{mismatched.inspect}"
    end
  end

  match do |actual|
    target = actual.is_a?(Class) ? actual : actual.class
    next false unless target.respond_to?(:retry_on)

    retry_cfg = target.retry_on
    next false unless retry_cfg.exceptions.include?(exception)
    next true if expected.empty?

    expected.all? { |k, v| retry_cfg.public_send(k) == v }
  end
end
