# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_been_rolled_back matcher" do
  it "passes when rollback ran" do
    task_class = create_failing_task do
      define_method(:rollback) { context.rolled_back = true }
    end
    result = task_class.execute(CMDx::Context.new)
    expect(result).to have_been_rolled_back
  end

  it "fails for a successful result" do
    expect(create_successful_task.execute(CMDx::Context.new)).not_to have_been_rolled_back
  end

  it "fails for a failed task without rollback" do
    expect(create_failing_task.execute(CMDx::Context.new)).not_to have_been_rolled_back
  end

  it "accepts a deferred result fixture" do
    deferred = CMDx::RSpec::Result.for.and_fail.rolled_back

    expect(deferred).to have_been_rolled_back
  end

  it "raises ArgumentError for non-result input" do
    not_a_result = :nope

    expect { expect(not_a_result).to have_been_rolled_back }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes" do
    expect(have_been_rolled_back.description).to eq("have been rolled back")
  end
end
