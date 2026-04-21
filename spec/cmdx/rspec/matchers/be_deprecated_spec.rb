# frozen_string_literal: true

require "spec_helper"

RSpec.describe "be_deprecated matcher" do
  describe "basic deprecation checking" do
    context "when task is not deprecated" do
      it "fails with appropriate message" do
        task_class = create_task_class(name: "TestTask")

        expect(task_class).not_to be_deprecated
      end
    end

    context "when task is deprecated" do
      it "passes" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:warn)

        expect(task_class).to be_deprecated
      end
    end
  end

  describe "behavior-specific checking" do
    context "with :warn behavior" do
      it "passes for warn behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:warn)

        expect(task_class).to be_deprecated(:warn)
        expect(task_class).to be_deprecated.with_warning
      end

      it "fails for other behaviors" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:warn)

        expect(task_class).not_to be_deprecated(:log)
        expect(task_class).not_to be_deprecated(:error)
        expect(task_class).not_to be_deprecated.with_logging
        expect(task_class).not_to be_deprecated.with_error
      end
    end

    context "with :log behavior" do
      it "passes for log behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:log)

        expect(task_class).to be_deprecated(:log)
        expect(task_class).to be_deprecated.with_logging
      end

      it "fails for other behaviors" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:log)

        expect(task_class).not_to be_deprecated(:warn)
        expect(task_class).not_to be_deprecated(:error)
        expect(task_class).not_to be_deprecated.with_warning
        expect(task_class).not_to be_deprecated.with_error
      end
    end

    context "with :error behavior" do
      it "passes for error behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:error)

        expect(task_class).to be_deprecated(:error)
        expect(task_class).to be_deprecated.with_error
      end

      it "fails for other behaviors" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:error)

        expect(task_class).not_to be_deprecated(:warn)
        expect(task_class).not_to be_deprecated(:log)
        expect(task_class).not_to be_deprecated.with_warning
        expect(task_class).not_to be_deprecated.with_logging
      end
    end

    context "with custom symbol behavior" do
      it "passes for matching behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:custom_handler)

        expect(task_class).to be_deprecated(:custom_handler)
        expect(task_class).to be_deprecated.with_behavior(:custom_handler)
      end

      it "fails for non-matching behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:custom_handler)

        expect(task_class).not_to be_deprecated(:other_handler)
        expect(task_class).not_to be_deprecated.with_behavior(:other_handler)
      end
    end
  end

  describe "chained matchers" do
    context "when with_warning" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:warn)

        expect(task_class).to be_deprecated.with_warning
      end
    end

    context "when with_logging" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:log)

        expect(task_class).to be_deprecated.with_logging
      end
    end

    context "when with_error" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:error)

        expect(task_class).to be_deprecated.with_error
      end
    end

    context "when with_behavior" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:custom_behavior)

        expect(task_class).to be_deprecated.with_behavior(:custom_behavior)
      end
    end
  end

  describe "edge cases" do
    context "when deprecation has not been declared" do
      it "is not deprecated" do
        task_class = create_task_class(name: "TestTask")

        expect(task_class).not_to be_deprecated
      end
    end

    context "when actual is an instance" do
      it "reads deprecation off the class" do
        task_class = create_task_class(name: "TestTask")
        task_class.deprecation(:warn)

        expect(task_class.new).to be_deprecated.with_warning
      end
    end
  end
end
