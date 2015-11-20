module Duty
  class Command
    def initialize(cmd, desciption, system)
      @cmd = cmd
      @desciption = desciption
      @system = system
      @executed = false
      @error = nil
    end

    def cmd
      @cmd
    end

    def pwd
      Dir.pwd
    end

    def describe
      @desciption
    end

    def executed?
      @executed
    end

    def error?
      !!error
    end

    def error
      if @executed == false
        'Stopped execution because something went wrong in a previous command'
      else
        @error
      end
    end

    def execute
      @executed = true
      stdout, stderr, status = @system.call(@cmd)
      @error = stderr if status != 0
    end
  end
end
