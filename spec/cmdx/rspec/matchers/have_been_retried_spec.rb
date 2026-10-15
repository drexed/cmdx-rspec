# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_been_retried matcher" do
  let(:task_class) do
    create_task_class do
      retry_on CMDx::TestError, limit: 2, delay: 0
      define_method(:work) do
        context.attempts = (context.attempts || 0) + 1
        raise CMDx::TestError, "boom" if context.attempts < 3
      end
    end
  end

  it "passes for any retry when no count specified" do
    result = task_class.execute(CMDx::Context.new)
    expect(result).to have_been_retried
  end

  it "matches an explicit retry count" do
    result = task_class.execute(CMDx::Context.new)
    expect(result).to have_been_retried(2)
  end

  it "fails when the count differs" do
    result = task_class.execute(CMDx::Context.new)
    expect(result).not_to have_been_retried(99)
  end

  it "fails for a result that wasn't retried" do
    expect(create_successful_task.execute(CMDx::Context.new)).not_to have_been_retried
  end

  it "accepts a deferred result fixture" do
    deferred = CMDx::RSpec::Result.for.and_succeed.with_retries(2)

    expect(deferred).to have_been_retried(2)
  end

  it "raises ArgumentError for non-result input" do
    not_a_result = :nope

    expect { expect(not_a_result).to have_been_retried }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes count expectations in failure messages" do
    deferred = CMDx::RSpec::Result.for.and_succeed.with_retries(1)
    matcher = have_been_retried(3)

    expect(matcher.matches?(deferred)).to be(false)
    expect(matcher.failure_message).to include("3 times").and include("1")
  end
end
