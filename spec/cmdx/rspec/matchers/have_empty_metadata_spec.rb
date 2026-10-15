# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_empty_metadata matcher" do
  let(:empty_result) do
    create_task_class { define_method(:work) { :success } }.execute(CMDx::Context.new)
  end

  it "passes when metadata is empty" do
    expect(empty_result).to have_empty_metadata
  end

  it "fails when metadata is present" do
    result = create_skipping_task(user_id: 123).execute(CMDx::Context.new)

    expect { expect(result).to have_empty_metadata }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "fails when multiple metadata entries are present" do
    result = create_failing_task(session_id: "abc123", request_id: "req456").execute(CMDx::Context.new)

    expect { expect(result).to have_empty_metadata }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "accepts a deferred result fixture with empty metadata" do
    deferred = CMDx::RSpec::Result.for.and_succeed

    expect(deferred).to have_empty_metadata
  end

  it "fails when deferred metadata is not empty" do
    deferred = CMDx::RSpec::Result.for.and_succeed(metadata: { user_id: 1 })

    expect { expect(deferred).to have_empty_metadata }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "raises on non-Result input" do
    invalid_input = :nope

    expect { expect(invalid_input).to have_empty_metadata }.to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes" do
    expect(have_empty_metadata.description).to eq("have an empty metadata")
  end
end
