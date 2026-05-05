# frozen_string_literal: true

# Matcher to verify that a {CMDx::Workflow} class declares the given
# pipeline tasks. Compares the flattened, deduplicated pipeline against
# the expected task classes (order-sensitive).
#
# @example
#   expect(MyWorkflow).to have_pipeline_tasks(StepA, StepB, StepC)
#
# @example Order-insensitive variant
#   expect(MyWorkflow).to have_pipeline_tasks(StepA, StepC, StepB).in_any_order
RSpec::Matchers.define :have_pipeline_tasks do |*expected|
  description { "have pipeline tasks #{expected.inspect}" }

  failure_message do |actual|
    "expected #{actual} pipeline to be #{expected.inspect}, but was #{actual.pipeline.flat_map(&:tasks).uniq.inspect}"
  end

  match do |actual|
    raise ArgumentError, "must be a CMDx::Workflow" unless actual.is_a?(Class) && actual.include?(CMDx::Workflow)

    tasks = actual.pipeline.flat_map(&:tasks).uniq
    @any_order ? tasks.sort_by(&:object_id) == expected.sort_by(&:object_id) : tasks == expected
  end

  chain(:in_any_order) { @any_order = true }
end
