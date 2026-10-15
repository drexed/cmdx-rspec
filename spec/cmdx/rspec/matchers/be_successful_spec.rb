# frozen_string_literal: true

require "spec_helper"

RSpec.describe "be_successful matcher" do
  let(:result) { create_successful_task.execute(CMDx::Context.new) }

  it "passes for a successful result" do
    expect(result).to be_successful
  end

  it "validates state is COMPLETE" do
    expect(result).to be_successful(state: CMDx::Signal::COMPLETE)
  end

  it "validates status is SUCCESS" do
    expect(result).to be_successful(status: CMDx::Signal::SUCCESS)
  end

  it "accepts composable matchers in keyword args" do
    expect(result).to be_successful(metadata: be_a(Hash))
  end

  it "fails for a non-successful result" do
    failed = create_failing_task.execute(CMDx::Context.new)

    expect { expect(failed).to be_successful }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "accepts a deferred result fixture" do
    deferred = CMDx::RSpec::Result.for.and_succeed(metadata: { id: 1 })

    expect(deferred).to be_successful(metadata: { id: 1 })
  end

  it "raises on non-Result input" do
    invalid_input = :nope

    expect { expect(invalid_input).to be_successful }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes" do
    expect(be_successful.description).to eq("have been a success")
  end
end
