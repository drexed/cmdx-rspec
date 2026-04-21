# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_output matcher" do
  let(:task_class) do
    create_task_class do
      output :total, required: true
      output :note
      define_method(:work) { context.total = 1 }
    end
  end

  it "passes when output declared" do
    expect(task_class).to have_output(:total)
  end

  it "fails when output missing" do
    expect(task_class).not_to have_output(:absent)
  end

  it "matches required: true" do
    expect(task_class).to have_output(:total, required: true)
  end

  it "matches required: false" do
    expect(task_class).to have_output(:note, required: false)
  end
end
