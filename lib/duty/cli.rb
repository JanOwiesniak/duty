require 'duty/config_loader'
require 'duty/io'
require 'duty/registry'
require 'duty/plugins'
require 'duty/task_runner'
require 'duty/views'

module Duty
  class CLI
    attr_reader :registry

    def initialize(args)
      @input = Duty::IO::CLI::Input.new(args)
      @output = Duty::IO::CLI::Output.new($stdout, $stderr)
      @registry = Duty::Registry.instance
      load_plugins
    end

    def exec
      explain_duty if needs_help?
      complete_task if needs_completion?
      execute_task
    end

    private

    attr_reader :input, :output

    def explain_duty
      view.duty_explain
      exit 0
    end

    def needs_help?
      input.needs_help?
    end

    def complete_task
      view.task_complete
      exit 0
    end

    def needs_completion?
      input.needs_completion?
    end

    def execute_task
      begin
        try_to_run_task
      rescue NameError => error
        view.task_invalid(error)
      end
    end

    def try_to_run_task
      Duty::TaskRunner.run(view, input, registry)
    end

    def view
      if verbose?
        Duty::Views::CLI::Verbose.new(self, input, output)
      else
        Duty::Views::CLI::Normal.new(self, input, output)
      end
    end

    def verbose?
      input.verbose?
    end

    def load_plugins
      Duty::Plugins.load(config)
    end

    def config
      Duty::ConfigLoader.new.load(Dir.pwd)
    end
  end
end
