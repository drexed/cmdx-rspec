# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_matching_metadata matcher" do
  it "passes for a single matching key" do
    result = create_skipping_task(user_id: 123).execute(CMDx::Context.new)

    expect(result).to have_matching_metadata(user_id: 123)
  end

  it "passes for multiple matching keys" do
    result = create_failing_task(user_id: 123, session_id: "abc123", request_id: "req456").execute(CMDx::Context.new)

    expect(result).to have_matching_metadata(user_id: 123, session_id: "abc123")
  end

  it "passes for partial matching" do
    result = create_skipping_task(user_id: 123, session_id: "abc123", request_id: "req456").execute(CMDx::Context.new)

    expect(result).to have_matching_metadata(session_id: "abc123")
  end

  it "passes for an empty expectation when metadata is empty" do
    result = create_task_class { define_method(:work) { :success } }.execute(CMDx::Context.new)

    expect(result).to have_matching_metadata
  end

  it "fails for a non-empty expectation when metadata is empty" do
    result = create_task_class { define_method(:work) { :success } }.execute(CMDx::Context.new)

    expect { expect(result).to have_matching_metadata(user_id: 123) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "fails for mismatched values" do
    result = create_skipping_task(user_id: 123).execute(CMDx::Context.new)

    expect { expect(result).to have_matching_metadata(user_id: 456) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "fails for a missing key" do
    result = create_failing_task(user_id: 123).execute(CMDx::Context.new)

    expect { expect(result).to have_matching_metadata(session_id: "abc123") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "fails for a type mismatch" do
    result = create_skipping_task(user_id: "123").execute(CMDx::Context.new)

    expect { expect(result).to have_matching_metadata(user_id: 123) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "passes for string metadata values" do
    result = create_failing_task(message: "hello world").execute(CMDx::Context.new)

    expect(result).to have_matching_metadata(message: "hello world")
  end

  it "passes for boolean metadata values" do
    result = create_skipping_task(enabled: true, debug: false).execute(CMDx::Context.new)

    expect(result).to have_matching_metadata(enabled: true, debug: false)
  end

  it "passes for array metadata values" do
    result = create_failing_task(tags: %w[ruby rspec testing]).execute(CMDx::Context.new)

    expect(result).to have_matching_metadata(tags: %w[ruby rspec testing])
  end

  it "passes for hash metadata values" do
    result = create_skipping_task(config: { timeout: 30, retries: 3 }).execute(CMDx::Context.new)

    expect(result).to have_matching_metadata(config: { timeout: 30, retries: 3 })
  end

  it "accepts composable matchers in keyword args" do
    deferred = CMDx::RSpec::Result.for.and_succeed(metadata: { user_id: 123 })

    expect(deferred).to have_matching_metadata(user_id: be_a(Integer))
  end

  it "accepts a deferred result fixture" do
    deferred = CMDx::RSpec::Result.for.and_succeed(metadata: { user_id: 123 })

    expect(deferred).to have_matching_metadata(user_id: 123)
  end

  it "delegates to have_empty_metadata when no keys are expected" do
    deferred = CMDx::RSpec::Result.for.and_succeed

    expect(deferred).to have_matching_metadata
  end

  it "raises on non-Result input" do
    invalid_input = { user_id: 1 }

    expect { expect(invalid_input).to have_matching_metadata(user_id: 1) }
      .to raise_error(ArgumentError, "must be a CMDx::Result")
  end

  it "describes" do
    expect(have_matching_metadata.description).to eq("have matching metadata")
  end
end
