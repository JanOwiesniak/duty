require 'duty/registry'
require 'duty/plugins'
require 'duty/meta'

module Duty
  class CLI
    DUTY_CONFIG_FILENAME = '.duty.yml'
    attr_reader :registry

    def initialize(args)
      @input = Input.new(args)
      @output = Output.new($stdout, $stderr)
      @registry = Duty::Registry.register(available_plugins)
    end

    def exec
      stdout usage if help?
      stdout completion if completion?
      execute_task
    end

    private

    def stdout(string)
      @output.print(string)
      exit 0
    end

    def available_plugins
      Duty::Plugins.load(DUTY_CONFIG_FILENAME)
    end

    def usage
      Duty::Meta::Help.new(self).to_s
    end

    def help?
      input.help?
    end

    def completion
      Duty::Meta::Completion.new(self, input.drop(1)).to_s
    end

    def completion?
      input.completion?
    end

    def execute_task
      begin
        try_to_run_task
      rescue NameError => e
        stdout invalid_task(e.message)
      end
    end

    def try_to_run_task
      TaskRunner.run(view, input, plugins)
    end

    def view
      verbose? ? VerboseView.new(output) : View.new(output)
    end

    def output
      @output
    end

    def input
      @input
    end

    def verbose?
      input.verbose?
    end

    def plugins
      @registry.plugins
    end

    def invalid_task(error_message)
      "duty: `#{input.join(' ')}` is not a duty task. Failed with: #{error_message}"
    end

    class TaskRunner
      def initialize(view, input, plugins)
        @view = view
        @input = input
        @plugins = plugins
      end

      def self.run(view, input, plugins)
        self.new(view, input, plugins).run
      end

      def run
        task_class.new(task_input, view).run
      end

      private

      attr_reader :view

      def task_class
        name = task_name.split('-').collect(&:capitalize).join
        @plugins.each do |plugin|
          plugin.tasks.each do |task_class|
            if task_class.to_s.split("::").last == name
              @task_class = task_class
            end
          end
        end
        @task_class
      end

      def task_input
        @input.task_input
      end

      def task_name
        @input.task_name
      end
    end

    class Input
      def initialize(args)
        @args = [args].flatten
      end

      def[](index)
        @args[index]
      end

      def task_name
        task, *rest = @args
        task
      end

      def task_input
        task, *rest = @args
        rest
      end

      def drop(index)
        @args.drop(1)
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
      def initialize(stdout, stderr)
        @stdout = stdout
        @stderr = stderr
      end

      def print(*args)
        @stdout.puts(*args)
      end

      def error(*args)
        @stderr.puts(*args)
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
