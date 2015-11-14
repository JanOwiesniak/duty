module Duty
  class CLI
    def initialize(args)
      @args = args
    end

    def exec
      stdout usage if missing_command?
      stdout execute_commands(@args)
    end

    private

    def stdout(string)
      $stdout.puts string
      exit 0
    end

    def strip(string)
      string.gsub(/ +/, " ").gsub(/^ +/, "")
    end

    def usage
      commands_description = Duty::Commands::Registry.all.map do |klass|
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
