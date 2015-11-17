module Duty
  # A command is an abstraction of something that has to be executed.
  # The most common instance of this will be Shell commands.
  class Command
    attr_reader :cmd, :describe

    def initialize(cmd, description, system)
      @cmd = cmd
      @describe = description
      @system = system
      @executed = false
      @error = nil
    end

    def executed?
      @executed
    end

    def error?
      !!error
    end

    def error
      if @executed == false
        'Not executed'
      else
        @error
      end
    end

    def execute
      raise NotImplementedError
    end

    class Shell < self
      def pwd
        Dir.pwd
      end

      def execute
        @executed = true
        stdout, stderr, status = @system.call(@cmd)
        @error = stderr if status != 0
      end
    end
  end
end
