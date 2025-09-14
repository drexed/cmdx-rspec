# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_matching_metadata matcher" do
  describe "basic metadata matching" do
    context "when result has exact matching metadata" do
      it "passes for single key-value pair" do
        task_class = create_skipping_task(name: "TestTask", user_id: 123)
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata(user_id: 123)
      end

      it "passes for multiple key-value pairs" do
        task_class = create_failing_task(name: "TestTask", user_id: 123, session_id: "abc123", request_id: "req456")
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata(user_id: 123, session_id: "abc123")
      end

      it "passes for partial matching" do
        task_class = create_skipping_task(name: "TestTask", user_id: 123, session_id: "abc123", request_id: "req456")
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata(session_id: "abc123")
      end
    end

    context "when result has no metadata" do
      it "fails for non-empty expectation" do
        task_class = create_task_class(name: "TestTask") do
          define_method(:work) { :success }
        end
        result = task_class.execute(CMDx::Context.new)

        expect { expect(result).to have_matching_metadata(user_id: 123) }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "passes for empty expectation" do
        task_class = create_task_class(name: "TestTask") do
          define_method(:work) { :success }
        end
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata
      end
    end
  end

  describe "metadata validation" do
    context "with mismatched values" do
      it "fails for wrong value" do
        task_class = create_skipping_task(name: "TestTask", user_id: 123)
        result = task_class.execute(CMDx::Context.new)

        expect { expect(result).to have_matching_metadata(user_id: 456) }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "fails for missing key" do
        task_class = create_failing_task(name: "TestTask", user_id: 123)
        result = task_class.execute(CMDx::Context.new)

        expect { expect(result).to have_matching_metadata(session_id: "abc123") }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "fails for wrong type" do
        task_class = create_skipping_task(name: "TestTask", user_id: "123")
        result = task_class.execute(CMDx::Context.new)

        expect { expect(result).to have_matching_metadata(user_id: 123) }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with different data types" do
      it "passes for string values" do
        task_class = create_failing_task(name: "TestTask", message: "hello world")
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata(message: "hello world")
      end

      it "passes for boolean values" do
        task_class = create_skipping_task(name: "TestTask", enabled: true, debug: false)
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata(enabled: true, debug: false)
      end

      it "passes for array values" do
        task_class = create_failing_task(name: "TestTask", tags: %w[ruby rspec testing])
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata(tags: %w[ruby rspec testing])
      end

      it "passes for hash values" do
        task_class = create_skipping_task(name: "TestTask", config: { timeout: 30, retries: 3 })
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_metadata(config: { timeout: 30, retries: 3 })
      end
    end
  end
end
