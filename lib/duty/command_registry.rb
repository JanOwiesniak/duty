require 'duty/commands/base'

module Duty
  module CommandRegistry
    class << self
      attr_accessor :commands

      def all
        all_names = Duty::Commands.constants - [:Base]
        all_names.map do |name|
          Duty::Commands.const_get(name)
        end
      end

      def require_all
        lib_dir = File.expand_path(File.join(__dir__, ".."))
        Dir[File.expand_path(File.join(__dir__, "commands", "*.rb"))].each do |path|
          require path.gsub(lib_dir+'/', '').gsub(/(\.rb)$/, '')
        end
      end
    end
  end
end
