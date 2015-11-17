module Duty
  class Worker
    def initialize(commands)
      @commands = commands
      @executed = []
    end

    def execute
      @commands.each do |command|
        command.execute
        @executed << command
      end
    end

    def executed
      @executed
    end
  end
end
