module Duty
  class CLI
    def initialize(args)
      @args = args
    end

    def exec
      write ExplainUsage.new if missing_command? 
      write ExplainInvalidCommand.new(@args) if invalid_command?
      write ExecuteCommand.new(@args)
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

    # Extract into high level command
    class ExplainUsage
      def message
        <<-msg
          usage: duty <command> [<args>]

          Commands:

          new-feature\tCreates a new feature branch
        msg
      end
    end

    # Extract into high level command
    class ExplainInvalidCommand
      def initialize(args)
        @args = args
      end

      def message
        <<-msg
          duty: `#{args}` is not a duty command
        msg
      end

      private

      def args
        @args.join(' ')
      end
    end

    # Extract into command - Should know about all high level command
    class ExecuteCommand
      def initialize(args)
        @args = args
      end

      def message
        if args[1]
          executor = Duty::Commands::NewFeature.new(args[1]).call
          SummaryCommand.new(executor).message
        else
          Duty::Commands::NewFeature.new.usage
        end
      end

      def args
        @args
      end
    end

    # Extract into low level command
    class SummaryCommand
      def initialize(executor)
        @executor = executor
      end

      def message
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

    def write(command)
      message = command.message
      $stdout.puts remove_starting_whitespaces(message) 
      exit 0
    end

    def remove_starting_whitespaces(msg)
      msg.gsub(/^ +/,'')
    end
  end
end
