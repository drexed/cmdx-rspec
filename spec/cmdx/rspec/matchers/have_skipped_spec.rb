# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_skipped matcher" do
  let(:result) { create_skipping_task.execute(CMDx::Context.new) }

  it "passes for a skipped result" do
    expect(result).to have_skipped
  end

  it "validates state is INTERRUPTED" do
    expect(result).to have_skipped(state: CMDx::Signal::INTERRUPTED)
  end

  it "validates status is SKIPPED" do
    expect(result).to have_skipped(status: CMDx::Signal::SKIPPED)
  end

  it "accepts composable matchers in keyword args" do
    expect(create_skipping_task(reason: "nope").execute(CMDx::Context.new)).to have_skipped(reason: be_a(String))
  end

  it "fails for a successful result" do
    ok = create_successful_task.execute(CMDx::Context.new)

    expect { expect(ok).to have_skipped }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "accepts a deferred result fixture" do
    deferred = CMDx::RSpec::Result.for.and_skip(reason: "not applicable")

    expect(deferred).to have_skipped(reason: "not applicable")
  end

  it "raises on non-Result input" do
    invalid_input = :nope

    expect { expect(invalid_input).to have_skipped }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes" do
    expect(have_skipped.description).to eq("have been skipped")
  end
end
