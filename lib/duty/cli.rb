module Duty
  class CLI
    def initialize(args)
      @args = args
    end

    def exec
      write ExplainUsage.new if missing_command? 
      write InvalidCommand.new(@args) if invalid_command?
      write NewFeature.new(@args) if new_feature?
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

    def new_feature?
      @args[0] == 'new-feature'
    end

    class ExplainUsage
      def message
        <<-msg
          usage: duty <command> [<args>]

          Commands:

          new-feature\tCreates a new feature branch
        msg
      end
    end

    class InvalidCommand
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

    class NewFeature
      def initialize(args)
        @args = args
      end

      def message
        if args[1]
          Success.new(args[1]).message
        else
          Explain.new.message
        end
      end

      def args
        @args
      end

      private

      class Success
        def initialize(name)
          @name = name
        end

        def message
          <<-msg
          What just happend:

          #{bullet} Checked out `master` branch
          #{bullet} Created new feature branch `feature\/#{name}`
          #{bullet} Checked out new feature branch `feature\/#{name}`
          #{bullet} Pushed new feature branch `feature\/#{name}` to `origin`
          msg
        end

        private

        def name
          @name
        end

        def bullet
          "\u2022".encode('utf-8')
        end
      end

      class Explain
        def message
          <<-msg
          Creates a new feature branch

          usage: duty new-feature <name>
          msg
        end
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
