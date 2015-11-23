require 'duty/registry'
require 'duty/meta'
require 'yaml'

module Duty
  class CLI
    attr_reader :registry
    DUTY_CONFIG_FILENAME = '.duty.yml'

    def initialize(args)
      @args = args
      boot_registry
    end

    def exec
      stdout usage if needs_help?
      stdout completion if needs_completion?
      execute_tasks(@args)
    end

    private

    def boot_registry
      @registry = Duty::Registry.new(additional_task_dir).tap {|r| r.require_all}
    end

    def additional_task_dir
      if File.exists?(DUTY_CONFIG_FILENAME)
        duty_config = load_config(DUTY_CONFIG_FILENAME)
        task_dir = duty_config["tasks"]
        if Dir.exists?(task_dir)
          task_dir
        else
          error_message = <<-EOF
Oops something went wrong!

You defined `#{task_dir}` as an additional tasks dir but this dir does not exist.
Please check the `tasks` section in your `#{DUTY_CONFIG_FILENAME}` file.
          EOF

          print error_message
          exit -1
        end
      end
    end

    def load_config(filename)
      YAML.load(File.read(filename))
    end

    def stdout(string)
      $stdout.puts string
      exit 0
    end

    def usage
      Duty::Meta::Help.new(self).to_s
    end

    def needs_help?
      @args.empty? || @args == %w(-h) || @args == %w(--help)
    end

    def completion
      Duty::Meta::Completion.new(self, @args.drop(1)).to_s
    end

    def needs_completion?
      @args.first == '--cmplt'
    end

    def execute_tasks(args)
      begin
        task = task_for(args)
        task.run
      rescue NameError => e
        stdout invalid_task(args, e.message)
      end
    end

    def task_for(args)
      task_string, *rest = args
      arguments = Arguments.new(rest)
      task_class_for(task_string).new(arguments, view)
    end

    def view
      if verbose?
        VerboseView.new(out)
      else
        View.new(out)
      end
    end

    def out
      Out.new
    end

    def verbose?
      @args.include?('-v') ||
      @args.include?('--verbose')
    end

    class Arguments
      def initialize(args)
        @args = [args].flatten
      end

      def[](index)
        @args[index]
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
      def command_failure(command)
        description = command.description
        error = command.error
        failure([description, error].join(' Error: '))
      end
    end

    class Out
      def print(*args)
        $stdout.puts(*args)
      end

      def error(*args)
        $stderr.puts(*args)
      end
    end

    def task_class_for(string)
      task_class = task_to_class_name(string)
      Object.const_get("Duty::Tasks::#{task_class}")
    end

    def task_to_class_name(string)
      string.split('-').collect(&:capitalize).join
    end

    def invalid_task(args, error_message)
      "duty: `#{args.join(' ')}` is not a duty task. Failed with: #{error_message}"
    end
  end
end
