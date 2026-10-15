# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_failed matcher" do
  let(:result) { create_failing_task.execute(CMDx::Context.new) }

  it "passes for a failed result" do
    expect(result).to have_failed
  end

  it "validates state is INTERRUPTED" do
    expect(result).to have_failed(state: CMDx::Signal::INTERRUPTED)
  end

  it "validates status is FAILED" do
    expect(result).to have_failed(status: CMDx::Signal::FAILED)
  end

  it "accepts composable matchers in keyword args" do
    expect(create_failing_task(reason: "nope").execute(CMDx::Context.new)).to have_failed(reason: be_a(String))
  end

  it "fails for a successful result" do
    ok = create_successful_task.execute(CMDx::Context.new)

    expect { expect(ok).to have_failed }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "accepts a deferred result fixture" do
    deferred = CMDx::RSpec::Result.for.and_fail(reason: "nope")

    expect(deferred).to have_failed(reason: "nope")
  end

  it "raises on non-Result input" do
    invalid_input = :nope

    expect { expect(invalid_input).to have_failed }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes" do
    expect(have_failed.description).to eq("have been a failure")
  end
end
