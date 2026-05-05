# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_errors_on matcher" do
  let(:task_class) do
    create_task_class do
      define_method(:work) do
        errors.add(:email, "is required")
        errors.add(:email, "is invalid")
      end
    end
  end

  it "passes when key has any error" do
    expect(task_class.execute(CMDx::Context.new)).to have_errors_on(:email)
  end

  it "passes when message matches" do
    expect(task_class.execute(CMDx::Context.new)).to have_errors_on(:email, "is required")
  end

  it "passes when all messages match" do
    expect(task_class.execute(CMDx::Context.new)).to have_errors_on(:email, "is required", "is invalid")
  end

  it "fails when message doesn't match" do
    expect(task_class.execute(CMDx::Context.new)).not_to have_errors_on(:email, "missing")
  end

  it "fails when key absent" do
    expect(task_class.execute(CMDx::Context.new)).not_to have_errors_on(:other)
  end

  it "accepts a task instance" do
    task = task_class.new(CMDx::Context.new)
    task.send(:work)
    expect(task).to have_errors_on(:email)
  end
end
