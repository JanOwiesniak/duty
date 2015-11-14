require 'duty/commands/registry'

module Duty
  class CLI
    def initialize(args)
      @args = args
      boot_registry
    end

    def exec
      stdout usage if missing_command?
      stdout execute_commands(@args)
    end

    private

    def boot_registry
      @registry = Duty::Commands::Registry.new(additional_command_dir).tap {|r| r.require_all}
    end

    def additional_command_dir
      if File.exists?(duty_file)
        duty_config = File.read(duty_file)
        command_dir_regexp = /commands:\s*(.*)/
        command_dir = duty_config.match(command_dir_regexp)[1]
        if Dir.exists?(command_dir)
          command_dir 
        else
          error_message = <<-EOF
Oops something went wrong!

You defined `#{command_dir}` as an additional commands dir but this dir does not exist.
Please check the `commands` section in your `.duty` file.
          EOF

          print error_message
          exit -1
        end
      end
    end

    def duty_file
      '.duty'
    end

    def registry
      @registry
    end

    def stdout(string)
      $stdout.puts string
      exit 0
    end

    def strip(string)
      string.gsub(/ +/, " ").gsub(/^ +/, "")
    end

    def usage
      commands_description = registry.all.map do |klass|
        "  " + command_name_for(klass).ljust(20) + klass.description
      end.join("\n")

      msg = <<-EOF
Usage: duty <command> [<args>]

Commands:

#{commands_description}
      EOF
    end

    def missing_command?
      @args.empty?
    end

    def execute_commands(args)
      begin
        command = command_for(args)
      rescue NameError => e
        return invalid_command(args)
      end

      present(command)
    end

    def command_for(args)
      command_string, *rest = args
      command_class_for(command_string).new(rest)
    end

    def command_class_for(string)
      command_class = command_to_class_name(string)
      Object.const_get("Duty::Commands::#{command_class}")
    end

    def command_name_for(klass)
      klass.to_s.
        gsub(Commands::Registry::COMMAND_NAMESPACE.to_s+"::", "").
        gsub(/([A-Z])/, '-\1').
        split('-').
        reject(&:empty?).
        map(&:downcase).
        join('-')
    end

    def command_to_class_name(string)
      string.split('-').collect(&:capitalize).join
    end

    def invalid_command(args)
      "duty: `#{args.join(' ')}` is not a duty command"
    end

    def present(command)
      presenter_for(command).present
    end

    def presenter_for(command)
      Presenter.new(command)
    end

    class Presenter
      def initialize(command)
        @command = command
      end

      def present
        if command.valid?
          executor = command.call
          summary = Summary.new(executor)
          summary.to_s
        else
          command.usage
        end
      end

      private

      def command
        @command
      end

      class Summary
        def initialize(executor)
          @executor = executor
        end

        def to_s
          <<-EOF
What just happend:

#{formatted}
          EOF
        end

        private

        def formatted
          commands = @executor.executed.map do |command|
            describe(command)
          end.join("\n")
        end

        def describe(command)
          "#{state(command)} #{command.describe}".tap do |s|
            s << error(command) if command.error?
          end
        end

        def state(command)
          command.error? ? cross_mark : check_mark
        end

        def error(command)
          " | Executed `#{command.cmd}` in `#{command.pwd}`, #{command.error}"
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
    end
  end
end
