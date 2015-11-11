module Duty
  class CLI
    def initialize(args)
      @args = args
    end

    def exec
      stdout ExplainDuty.new if missing_command? 
      stdout ExplainCommands.new(@args) if invalid_command?
      stdout ExecuteCommands.new(@args)
    end

    private

    def missing_command?
      @args.empty?
    end

    def invalid_command?
      !valid_commands.include? @args[0]
    end

    def valid_commands
      ['new-feature']
    end

    def stdout(command)
      string = command.to_s
      $stdout.puts remove_starting_whitespaces(string)
      exit 0
    end

    def remove_starting_whitespaces(msg)
      msg.gsub(/^ +/,'')
    end

    class ExplainDuty
      def to_s
        <<-msg
          usage: duty <command> [<args>]

          Commands:

          new-feature\tCreates a new feature branch
        msg
      end
    end

    class ExplainCommands
      def initialize(args)
        @args = args
      end

      def to_s
        <<-msg
          duty: `#{@args.join(' ')}` is not a duty command
        msg
      end
    end

    class ExecuteCommands
      def initialize(args)
        @args = args
      end

      def to_s
        if @args[1]
          executor = Duty::Commands::NewFeature.new(@args[1]).call
          ExecutionSummary.new(executor).to_s
        else
          Duty::Commands::NewFeature.new.usage
        end
      end
    end

    class ExecutionSummary
      def initialize(executor)
        @executor = executor
      end

      def to_s
        <<-msg
          What just happend:

        #{formatted}
        msg
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
