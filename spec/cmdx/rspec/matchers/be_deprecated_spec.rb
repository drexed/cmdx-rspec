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
        task_class.settings(deprecate: true)

        expect(task_class).to be_deprecated
      end
    end
  end

  describe "behavior-specific checking" do
    context "with :warn behavior" do
      it "passes for warn behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "warn")

        expect(task_class).to be_deprecated(:warn)
        expect(task_class).to be_deprecated.with_warning
      end

      it "fails for other behaviors" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "warn")

        expect(task_class).not_to be_deprecated(:log)
        expect(task_class).not_to be_deprecated(:raise)
        expect(task_class).not_to be_deprecated.with_logging
        expect(task_class).not_to be_deprecated.with_raise
      end
    end

    context "with :log behavior" do
      it "passes for log behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "log")

        expect(task_class).to be_deprecated(:log)
        expect(task_class).to be_deprecated.with_logging
      end

      it "fails for other behaviors" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "log")

        expect(task_class).not_to be_deprecated(:warn)
        expect(task_class).not_to be_deprecated(:raise)
        expect(task_class).not_to be_deprecated.with_warning
        expect(task_class).not_to be_deprecated.with_raise
      end
    end

    context "with :raise behavior" do
      it "passes for raise behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "raise")

        expect(task_class).to be_deprecated(:raise)
        expect(task_class).to be_deprecated.with_raise
      end

      it "fails for other behaviors" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "raise")

        expect(task_class).not_to be_deprecated(:warn)
        expect(task_class).not_to be_deprecated(:log)
        expect(task_class).not_to be_deprecated.with_warning
        expect(task_class).not_to be_deprecated.with_logging
      end
    end

    context "with true value" do
      it "passes for raise behavior (true defaults to raise)" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: true)

        expect(task_class).to be_deprecated(:raise)
        expect(task_class).to be_deprecated.with_raise
      end
    end

    context "with custom string behavior" do
      it "passes for matching behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "custom_warn")

        expect(task_class).to be_deprecated("custom_warn")
        expect(task_class).to be_deprecated.with_behavior("custom_warn")
      end

      it "fails for non-matching behavior" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "custom_warn")

        expect(task_class).not_to be_deprecated("custom_log")
        expect(task_class).not_to be_deprecated.with_behavior("custom_log")
      end
    end
  end

  describe "chained matchers" do
    context "when with_warning" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "warn")

        expect(task_class).to be_deprecated.with_warning
      end
    end

    context "when with_logging" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "log")

        expect(task_class).to be_deprecated.with_logging
      end
    end

    context "when with_raise" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "raise")

        expect(task_class).to be_deprecated.with_raise
      end
    end

    context "when with_behavior" do
      it "works correctly" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "custom_behavior")

        expect(task_class).to be_deprecated.with_behavior("custom_behavior")
      end
    end
  end

  describe "edge cases" do
    context "with nil deprecate setting" do
      it "is not deprecated" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: nil)

        expect(task_class).not_to be_deprecated
      end
    end

    context "with false deprecate setting" do
      it "is not deprecated" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: false)

        expect(task_class).not_to be_deprecated
      end
    end

    context "with regex behavior matching" do
      it "matches partial strings" do
        task_class = create_task_class(name: "TestTask")
        task_class.settings(deprecate: "my_warning_system")

        expect(task_class).to be_deprecated(:warn)
        expect(task_class).to be_deprecated.with_warning
      end
    end
  end
end
