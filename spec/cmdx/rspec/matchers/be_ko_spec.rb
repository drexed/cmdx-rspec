# frozen_string_literal: true

require "spec_helper"

RSpec.describe "be_ko matcher" do
  it "passes for a skipped result" do
    expect(create_skipping_task.execute(CMDx::Context.new)).to be_ko
  end

  it "passes for a failed result" do
    expect(create_failing_task.execute(CMDx::Context.new)).to be_ko
  end

  it "fails for a successful result" do
    expect(create_successful_task.execute(CMDx::Context.new)).not_to be_ko
  end

  it "raises on non-Result input" do
    expect { expect(:nope).to be_ko }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end
end
