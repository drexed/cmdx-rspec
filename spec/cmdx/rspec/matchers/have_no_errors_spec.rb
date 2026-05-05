# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_no_errors matcher" do
  it "passes for a clean result" do
    expect(create_successful_task.execute(CMDx::Context.new)).to have_no_errors
  end

  it "fails when errors are present" do
    task_class = create_task_class do
      define_method(:work) { errors.add(:base, "bad") }
    end
    expect(task_class.execute(CMDx::Context.new)).not_to have_no_errors
  end
end
