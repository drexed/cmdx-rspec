# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_matching_context matcher" do
  describe "empty expectation" do
    context "when no keys are expected" do
      it "delegates to have_empty_context for a Hash" do
        context = {}

        expect(context).to have_matching_context
      end

      it "delegates to have_empty_context for an empty CMDx::Context" do
        expect(CMDx::Context.new).to have_matching_context
      end

      it "delegates to have_empty_context for a result with empty context" do
        task_class = create_task_class(name: "TestTask") do
          define_method(:work) { :success }
        end
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_matching_context
      end

      it "fails when the Hash is not empty" do
        context = { user_id: 1 }

        expect { expect(context).to have_matching_context }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end

  describe "basic context matching" do
    context "when context is a Hash" do
      it "passes for exact match" do
        context = { user_id: 123, role: "admin" }

        expect(context).to have_matching_context(user_id: 123, role: "admin")
      end

      it "passes for partial match" do
        context = { user_id: 123, role: "admin", session_id: "abc123" }

        expect(context).to have_matching_context(user_id: 123, role: "admin")
      end

      it "fails for missing keys" do
        context = { user_id: 123 }

        expect { expect(context).to have_matching_context(user_id: 123, role: "admin") }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "fails for mismatched values" do
        context = { user_id: 123, role: "user" }

        expect { expect(context).to have_matching_context(user_id: 123, role: "admin") }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "when context is a CMDx::Context" do
      it "passes for matching data" do
        context = CMDx::Context.new
        context[:user_id] = 123
        context[:role] = "admin"

        expect(context).to have_matching_context(user_id: 123, role: "admin")
      end

      it "passes for partial match" do
        context = CMDx::Context.new
        context[:user_id] = 123
        context[:role] = "admin"
        context[:session_id] = "abc123"

        expect(context).to have_matching_context(user_id: 123, role: "admin")
      end

      it "fails for missing data" do
        context = CMDx::Context.new
        context[:user_id] = 123

        expect { expect(context).to have_matching_context(user_id: 123, role: "admin") }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "when context is a deferred result fixture" do
      it "passes for matching context data" do
        deferred = CMDx::RSpec::Result.for(user_id: 123, role: "admin").and_succeed

        expect(deferred).to have_matching_context(user_id: 123, role: "admin")
      end

      it "delegates to have_empty_context when no keys are expected" do
        deferred = CMDx::RSpec::Result.for.and_succeed

        expect(deferred).to have_matching_context
      end
    end

    context "when context is a CMDx::Result" do
      it "passes for matching context data" do
        context = CMDx::Context.new
        context[:user_id] = 123
        context[:role] = "admin"

        task_class = create_successful_task(name: "TestTask")
        result = task_class.execute(context)

        expect(result).to have_matching_context(user_id: 123, role: "admin")
      end

      it "passes for partial match" do
        context = CMDx::Context.new
        context[:user_id] = 123
        context[:role] = "admin"
        context[:session_id] = "abc123"

        task_class = create_successful_task(name: "TestTask")
        result = task_class.execute(context)

        expect(result).to have_matching_context(user_id: 123, role: "admin")
      end

      it "fails for missing context data" do
        context = CMDx::Context.new
        context[:user_id] = 123

        task_class = create_successful_task(name: "TestTask")
        result = task_class.execute(context)

        expect { expect(result).to have_matching_context(user_id: 123, role: "admin") }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end

  describe "complex data types" do
    context "with nested hashes" do
      it "passes for exact nested structure match" do
        context = { user: { id: 123, profile: { role: "admin" } } }

        expect(context).to have_matching_context(user: { id: 123, profile: { role: "admin" } })
      end

      it "fails for partial nested match" do
        context = { user: { id: 123, profile: { role: "admin", email: "test@example.com" } } }
        expect { expect(context).to have_matching_context(user: { id: 123, profile: { role: "admin" } }) }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with arrays" do
      it "passes for exact array match" do
        context = { permissions: %w[read write admin] }

        expect(context).to have_matching_context(permissions: %w[read write admin])
      end

      it "fails for partial array match" do
        context = { permissions: %w[read write admin delete] }

        expect { expect(context).to have_matching_context(permissions: %w[read write admin]) }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with mixed types" do
      it "passes for mixed data types" do
        context = {
          user_id: 123,
          active: true,
          tags: %w[admin moderator],
          metadata: { created_at: "2024-01-01" }
        }

        expect(context).to have_matching_context(
          user_id: 123,
          active: true,
          tags: %w[admin moderator]
        )
      end
    end
  end

  describe "edge cases" do
    context "with minimal data hash" do
      it "passes for any context with at least one key" do
        context = { user_id: 123, role: "admin" }

        expect(context).to have_matching_context(user_id: 123)
      end
    end

    context "with nil values" do
      it "passes for explicit nil values" do
        context = { user_id: nil, role: "admin" }

        expect(context).to have_matching_context(user_id: nil, role: "admin")
      end

      it "fails for missing nil key" do
        context = { role: "admin" }

        expect { expect(context).to have_matching_context(user_id: nil, role: "admin") }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with boolean values" do
      it "passes for boolean match" do
        context = { active: true, verified: false }

        expect(context).to have_matching_context(active: true, verified: false)
      end
    end

    context "with numeric values" do
      it "passes for integer match" do
        context = { count: 42, limit: 100 }

        expect(context).to have_matching_context(count: 42, limit: 100)
      end

      it "passes for float match" do
        context = { score: 95.5, threshold: 90.0 }

        expect(context).to have_matching_context(score: 95.5, threshold: 90.0)
      end
    end
  end

  describe "nested matchers" do
    it "accepts composable matchers in keyword args" do
      context = { user_id: 123 }

      expect(context).to have_matching_context(user_id: be_a(Integer))
    end
  end

  describe "error handling" do
    context "with unsupported input types" do
      it "raises error for nil with expected keys" do
        invalid_input = nil

        expect { expect(invalid_input).to have_matching_context(key: "value") }.to raise_error("unknown context type NilClass")
      end

      it "raises error for arbitrary object" do
        expect { expect(Object.new).to have_matching_context(key: "value") }.to raise_error(/unknown context type Object/)
      end
    end
  end

  it "describes" do
    expect(have_matching_context.description).to eq("have matching context")
  end
end
