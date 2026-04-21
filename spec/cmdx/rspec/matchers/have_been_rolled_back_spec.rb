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
end
