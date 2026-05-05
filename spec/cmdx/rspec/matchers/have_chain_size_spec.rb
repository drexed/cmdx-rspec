# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_chain_size matcher" do
  it "matches the chain size of a single task" do
    result = create_successful_task.execute(CMDx::Context.new)
    expect(result).to have_chain_size(1)
  end

  it "matches via Chain directly" do
    result = create_successful_task.execute(CMDx::Context.new)
    expect(result.chain).to have_chain_size(1)
  end

  it "fails on size mismatch" do
    result = create_successful_task.execute(CMDx::Context.new)
    expect(result).not_to have_chain_size(99)
  end
end
