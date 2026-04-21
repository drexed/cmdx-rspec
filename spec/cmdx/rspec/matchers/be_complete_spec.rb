# frozen_string_literal: true

require "spec_helper"

RSpec.describe "be_complete matcher" do
  it "passes for a successful result" do
    result = create_successful_task.execute(CMDx::Context.new)
    expect(result).to be_complete
  end

  it "fails for a skipped result" do
    result = create_skipping_task.execute(CMDx::Context.new)
    expect(result).not_to be_complete
  end

  it "fails for a failed result" do
    result = create_failing_task.execute(CMDx::Context.new)
    expect(result).not_to be_complete
  end

  it "raises on non-Result input" do
    expect { expect(:nope).to be_complete }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes" do
    expect(be_complete.description).to eq("have completed")
  end
end
