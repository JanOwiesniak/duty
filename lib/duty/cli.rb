require 'duty/commands/registry'
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
      execute_commands(@args)
    end

    private

    def boot_registry
      @registry = Duty::Commands::Registry.new(additional_command_dir).tap {|r| r.require_all}
    end

    def additional_command_dir
      if File.exists?(DUTY_CONFIG_FILENAME)
        duty_config = load_config(DUTY_CONFIG_FILENAME)
        command_dir = duty_config["commands"]
        if Dir.exists?(command_dir)
          command_dir
        else
          error_message = <<-EOF
Oops something went wrong!

You defined `#{command_dir}` as an additional commands dir but this dir does not exist.
Please check the `commands` section in your `#{DUTY_CONFIG_FILENAME}` file.
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

    def execute_commands(args)
      begin
        command = command_for(args)
        command.run
      rescue NameError => e
        stdout invalid_command(args, e.message)
      end
    end

    def command_for(args)
      command_string, *rest = args
      arguments = Arguments.new(rest)
      view = View.new(Out.new)
      command_class_for(command_string).new(arguments, view)
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

      def add_message(msg)
        @output.print(msg)
      end

      def add_success(msg)
        @output.print([check_mark, msg].join(' '))
      end

      def add_failure(msg)
        @output.error([cross_mark, msg].join(' '))
      end

      private

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

    class Out
      def print(*args)
        $stdout.puts(*args)
      end

      def error(*args)
        $stderr.puts(*args)
      end
    end

    def command_class_for(string)
      command_class = command_to_class_name(string)
      Object.const_get("Duty::Commands::#{command_class}")
    end

    def command_to_class_name(string)
      string.split('-').collect(&:capitalize).join
    end

    def invalid_command(args, error_message)
      "duty: `#{args.join(' ')}` is not a duty command. Failed with: #{error_message}"
    end
  end
end
