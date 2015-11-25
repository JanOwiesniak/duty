require 'duty/registry'
require 'duty/plugins'
require 'duty/meta'

module Duty
  class CLI
    DUTY_CONFIG_FILENAME = '.duty.yml'
    attr_reader :registry

    def initialize(args)
      @input = Input.new(args)
      @output = Output.new
      @registry = Duty::Registry.load(plugins)
    end

    def exec
      stdout usage if help?
      stdout completion if completion?
      run_task
    end

    private

    attr_reader :input, :output

    def plugins
      Duty::Plugins.load(DUTY_CONFIG_FILENAME)
    end

    def stdout(string)
      $stdout.puts string
      exit 0
    end

    def help?
      input.help?
    end

    def usage
      Duty::Meta::Help.new(self).to_s
    end

    def completion?
      input.completion?
    end

    def completion
      Duty::Meta::Completion.new(self, input.drop(1)).to_s
    end

    def run_task
      begin
        task.run
      rescue NameError => e
        stdout invalid_task(e.message)
      end
    end

    def task
      input.task_class.new(input.task_input, view)
    end

    def invalid_task(error_message)
      "duty: `#{input.join(' ')}` is not a duty task. Failed with: #{error_message}"
    end

    def view
      if verbose?
        VerboseView.new(output)
      else
        View.new(output)
      end
    end

    def verbose?
      input.verbose?
    end

    class Input
      def initialize(args)
        @args = [args].flatten
      end

      def[](index)
        @args[index]
      end

      def drop(index)
        @args.drop(1)
      end

      def task_name
        task, *rest = @args
        task
      end

      def task_class
        name = task_name.split('-').collect(&:capitalize).join
        Object.const_get("Duty::Tasks::#{name}")
      end

      def task_input
        task, *rest = @args
        rest
      end

      def join(seperator='')
        @args.join(seperator)
      end

      def verbose?
        @args.include?('-v') || @args.include?('--verbose')
      end

      def completion?
        @args.first == '--cmplt'
      end

      def help?
        @args.empty? || @args == %w(-h) || @args == %w(--help)
      end
    end

    class Output
      def print(*args)
        $stdout.puts(*args)
      end

      def error(*args)
        $stderr.puts(*args)
      end
    end

    class View
      def initialize(output)
        @output = output
      end

      def task_explain(task)
        task_class = task.class
        description = task_class.description
        usage = task_class.usage

        @output.print(description)
        @output.print(usage)
      end

      def task_success(task)
        task_name = task.class.name
        success("#{task_name} task executed")
      end

      def task_failure(task)
        task_name = task.class.name
        failure("#{task_name} task aborted")
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

      def success(msg)
        @output.print([check_mark, msg].join(' '))
      end

      def failure(msg)
        @output.error([cross_mark, msg].join(' '))
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
    end

    class VerboseView < View
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
