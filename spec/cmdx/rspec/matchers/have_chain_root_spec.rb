# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_chain_root matcher" do
  it "passes when root task class matches" do
    task_class = create_successful_task
    result = task_class.execute(CMDx::Context.new)
    expect(result).to have_chain_root(task_class)
  end

  it "matches Chain directly" do
    task_class = create_successful_task
    result = task_class.execute(CMDx::Context.new)
    expect(result.chain).to have_chain_root(task_class)
  end

  it "fails for a different class" do
    other = create_successful_task(name: "Other")
    result = create_successful_task.execute(CMDx::Context.new)
    expect(result).not_to have_chain_root(other)
  end
end
