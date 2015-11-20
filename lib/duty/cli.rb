require 'duty/commands/registry'
require 'duty/meta'

module Duty
  class CLI
    attr_reader :registry

    def initialize(args)
      @args = args
      boot_registry
    end

    def exec
      stdout usage if needs_help?
      stdout completion if needs_completion?
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

    def stdout(string)
      $stdout.puts string
      exit 0
    end

    def strip(string)
      string.gsub(/ +/, " ").gsub(/^ +/, "")
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
          worker = command.call
          summary = Summary.new(worker)
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
        def initialize(worker)
          @worker = worker
        end

        def to_s
          <<-EOF
What just happend:

#{formatted}
          EOF
        end

        private

        def formatted
          commands = @worker.processed.map do |command|
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
          status = command.executed? ? "Executed" : "Not Executed"
          " | #{status} `#{command.cmd}` in `#{command.pwd}`, #{command.error}"
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
