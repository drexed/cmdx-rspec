# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_empty_context matcher" do
  describe "basic empty context checking" do
    context "when context is an empty Hash" do
      it "passes" do
        expect({}).to have_empty_context
      end
    end

    context "when context is an empty CMDx::Context" do
      it "passes" do
        context = CMDx::Context.new

        expect(context).to have_empty_context
      end
    end

    context "when context is a CMDx::Result with empty context" do
      it "passes" do
        # Create a task that doesn't modify the context
        task_class = create_task_class(name: "TestTask") do
          define_method(:work) { :success }
        end
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_empty_context
      end
    end
  end

  describe "non-empty context validation" do
    context "with Hash containing data" do
      it "fails for non-empty hash" do
        expect { expect({ key: "value" }).to have_empty_context }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with CMDx::Context containing data" do
      it "fails for context with data" do
        context = CMDx::Context.new
        context[:user_id] = 123

        expect { expect(context).to have_empty_context }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with CMDx::Result containing data in context" do
      it "fails for result with non-empty context" do
        context = CMDx::Context.new
        context[:session_id] = "abc123"
        task_class = create_task_class(name: "TestTask") do
          define_method(:work) { :success }
        end
        result = task_class.execute(context)

        expect { expect(result).to have_empty_context }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end

  describe "edge cases" do
    context "with nil input" do
      it "raises error for nil" do
        expect { expect(nil).to have_empty_context }.to raise_error("unknown context type NilClass")
      end
    end

    context "with string input" do
      it "raises error for string" do
        expect { expect("not a context").to have_empty_context }.to raise_error("unknown context type String")
      end
    end

    context "with arbitrary object input" do
      it "raises error for arbitrary object" do
        expect { expect(Object.new).to have_empty_context }.to raise_error(/unknown context type Object/)
      end
    end
  end

  describe "matcher description" do
    it "provides clear description" do
      expect(have_empty_context.description).to eq("have an empty context")
    end
  end
end
