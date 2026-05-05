# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_tag matcher" do
  let(:task_class) do
    create_successful_task { settings tags: %i[critical billing] }
  end

  it "matches against a Result" do
    expect(task_class.execute(CMDx::Context.new)).to have_tag(:critical)
  end

  it "matches against a Task class" do
    expect(task_class).to have_tag(:billing)
  end

  it "fails when tag missing" do
    expect(task_class).not_to have_tag(:nope)
  end
end
