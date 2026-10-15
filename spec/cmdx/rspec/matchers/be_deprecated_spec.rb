# frozen_string_literal: true

require "spec_helper"

RSpec.describe "be_deprecated matcher" do
  let(:task_class) { create_task_class }

  it "fails when deprecation has not been declared" do
    expect(task_class).not_to be_deprecated
  end

  it "passes when deprecation is declared" do
    task_class.deprecation(:warn)

    expect(task_class).to be_deprecated
  end

  it "matches :warn behavior and with_warning" do
    task_class.deprecation(:warn)

    expect(task_class).to be_deprecated(:warn)
    expect(task_class).to be_deprecated.with_warning
    expect(task_class).not_to be_deprecated(:log)
    expect(task_class).not_to be_deprecated.with_logging
  end

  it "matches :log behavior and with_logging" do
    task_class.deprecation(:log)

    expect(task_class).to be_deprecated(:log)
    expect(task_class).to be_deprecated.with_logging
    expect(task_class).not_to be_deprecated(:warn)
    expect(task_class).not_to be_deprecated.with_error
  end

  it "matches :error behavior and with_error" do
    task_class.deprecation(:error)

    expect(task_class).to be_deprecated(:error)
    expect(task_class).to be_deprecated.with_error
    expect(task_class).not_to be_deprecated(:warn)
    expect(task_class).not_to be_deprecated.with_logging
  end

  it "matches a custom symbol behavior and with_behavior" do
    task_class.deprecation(:custom_handler)

    expect(task_class).to be_deprecated(:custom_handler)
    expect(task_class).to be_deprecated.with_behavior(:custom_handler)
    expect(task_class).not_to be_deprecated(:other_handler)
  end

  it "reads deprecation from a task instance" do
    task_class.deprecation(:warn)

    expect(task_class.new).to be_deprecated.with_warning
  end

  it "describes deprecation without a behavior filter" do
    expect(be_deprecated.description).to eq("be deprecated")
  end

  it "describes deprecation with a behavior filter" do
    expect(be_deprecated(:warn).description).to eq("be deprecated with behavior warn")
  end
end
