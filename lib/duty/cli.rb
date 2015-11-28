require 'duty/registry'
require 'duty/plugins'
require 'duty/meta'
require 'duty/views'
require 'duty/io'
require 'duty/task_runner'

module Duty
  class CLI
    DUTY_CONFIG_FILENAME = '.duty.yml'
    attr_reader :registry

    def initialize(args)
      @input = Duty::IO::CLI::Input.new(args)
      @output = Duty::IO::CLI::Output.new($stdout, $stderr)
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
      verbose? ? Duty::Views::CLI::Verbose.new(output) : Duty::Views::CLI::Normal.new(output)
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
  end
end
