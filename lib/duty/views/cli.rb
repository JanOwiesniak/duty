require 'duty/meta'

module Duty
  module Views
    module CLI
      class Normal
        def initialize(cli, input, output)
          @cli = cli
          @input = input
          @output = output
        end

        def duty_explain
          output.print meta_help_message 
        end

        def task_complete
          output.print meta_completion_message 
        end

        def task_explain(task)
          task_class = task.class
          description = task_class.description
          usage = task_class.usage

          output.print(description)
          output.print(usage)
        end

        def task_success(task)
          task_name = task.class.name
          success("#{task_name} task executed")
        end

        def task_failure(task)
          task_name = task.class.name
          failure("#{task_name} task aborted")
        end

        def task_invalid(error)
          error_message = "duty: `#{input.join(' ')}` is not a duty task. Failed with: #{error.message}"
          output.print error_message
        end

        def command_success(command)
          description = command.description
          success(description)
        end

        def command_failure(command)
          description = command.description
          failure(description)
        end

        private

        attr_reader :cli, :input, :output

        def success(msg)
          output.print([check_mark, msg].join(' '))
        end

        def failure(msg)
          output.error([cross_mark, msg].join(' '))
        end

        def cross_mark
          unicode("2715")
        end

        def check_mark
          unicode("2713")
        end

        def unicode(code)
          ["0x#{code}".hex].pack('U')
        end

        def meta_help_message
          Duty::Meta::Help.new(cli).to_s
        end

        def meta_completion_message
          Duty::Meta::Completion.new(cli, input.drop(1)).to_s
        end
      end

      class Verbose < Normal
        def command_success(command)
          success(command_msg(command))
        end

        def command_failure(command)
          failure(command_msg(command))
        end

        private

        def command_msg(command)
          [command.description, command_logs(command)].join(' ')
        end

        def command_logs(command)
          elements = command.logger.flatten

          if elements.any?
            ["|>", elements.join(' | ')].join(' ')
          end
        end
      end
    end
  end
end
