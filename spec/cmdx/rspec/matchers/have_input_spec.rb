# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_input matcher" do
  let(:task_class) do
    create_task_class do
      required :user_id, coerce: :integer
      optional :note
    end
  end

  it "passes when input declared" do
    expect(task_class).to have_input(:user_id)
  end

  it "fails when input missing" do
    expect(task_class).not_to have_input(:absent)
  end

  it "matches required: true" do
    expect(task_class).to have_input(:user_id, required: true)
  end

  it "matches required: false" do
    expect(task_class).to have_input(:note, required: false)
  end

  it "matches partially against options" do
    expect(task_class).to have_input(:user_id, options: hash_including(coerce: :integer))
  end

  it "fails when keys mismatch" do
    expect(task_class).not_to have_input(:user_id, required: false)
  end

  it "accepts an instance and reads the class" do
    expect(task_class.new(CMDx::Context.new)).to have_input(:user_id)
  end
end
