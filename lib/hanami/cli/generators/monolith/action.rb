# frozen_string_literal: true

require "erb"
require "dry/cli/utils/files"
require "hanami/cli/generators/monolith/action_context"

module Hanami
  module CLI
    module Generators
      module Monolith
        class Action
          def initialize(fs:, inflector:)
            @fs = fs
            @inflector = inflector
          end

          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/ParameterLists
          # rubocop:disable Layout/LineLength
          def call(slice, controller, action, format, skip_view, context: ActionContext.new(inflector, slice, controller, action))
            slice_directory = fs.join("slices", slice)
            raise ArgumentError.new("slice not found `#{slice}'") unless fs.directory?(slice_directory)

            fs.chdir(slice_directory) do
              fs.mkdir(directory = fs.join("actions", controller))
              fs.write(fs.join(directory, "#{action}.rb"), t("action.erb", context))

              unless skip_view
                fs.mkdir(directory = fs.join("views", controller))
                fs.write(fs.join(directory, "#{action}.rb"), t("view.erb", context))

                fs.mkdir(directory = fs.join("templates", controller))
                fs.write(fs.join(directory, "#{action}.#{format}.erb"), t(template_format(format), context))
              end
            end
          end
          # rubocop:enable Layout/LineLength
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/AbcSize

          private

          attr_reader :fs

          attr_reader :inflector

          def template_format(format)
            case format.to_sym
            when :html
              "template.html.erb"
            else
              "template.erb"
            end
          end

          def template(path, context)
            require "erb"

            ERB.new(
              File.read(__dir__ + "/action/#{path}")
            ).result(context.ctx)
          end

          alias_method :t, :template
        end
      end
    end
  end
end
