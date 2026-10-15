# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      module Support
        # Flattens a {CMDx::Workflow} pipeline into distinct task classes.
        #
        # @api private
        module PipelineTasks

          extend self

          # @param workflow [Class] workflow class including {CMDx::Workflow}
          # @return [Array<Class>] task classes in first-seen pipeline order
          def list(workflow)
            workflow.pipeline.flat_map(&:tasks).uniq
          end

        end
      end
    end
  end
end
