# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_duration matcher" do
  let(:result) { create_successful_task.execute(CMDx::Context.new) }

  it "matches less_than" do
    expect(result).to have_duration(less_than: 60_000)
  end

  it "matches greater_than" do
    expect(result).to have_duration(greater_than: -1)
  end

  it "matches both bounds" do
    expect(result).to have_duration(greater_than: -1, less_than: 60_000)
  end

  it "fails when out of bounds" do
    expect(result).not_to have_duration(less_than: 0)
  end

  it "raises without bounds" do
    expect { expect(result).to have_duration }.to raise_error(ArgumentError)
  end

  it "rejects non-Result input" do
    not_a_result = Object.new
    expect { expect(not_a_result).to have_duration(less_than: 1) }
      .to raise_error(ArgumentError, "must be a CMDx::Result")
  end
end
