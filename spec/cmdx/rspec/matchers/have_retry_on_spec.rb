# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_retry_on matcher" do
  let(:task_class) do
    create_task_class do
      retry_on CMDx::TestError, limit: 5, delay: 0.1, jitter: :exponential
    end
  end

  it "passes for the registered exception" do
    expect(task_class).to have_retry_on(CMDx::TestError)
  end

  it "fails for an unregistered exception" do
    expect(task_class).not_to have_retry_on(ArgumentError)
  end

  it "matches the limit option" do
    expect(task_class).to have_retry_on(CMDx::TestError, limit: 5)
  end

  it "matches multiple options" do
    expect(task_class).to have_retry_on(CMDx::TestError, limit: 5, jitter: :exponential)
  end

  it "fails when option mismatches" do
    expect(task_class).not_to have_retry_on(CMDx::TestError, limit: 99)
  end
end
