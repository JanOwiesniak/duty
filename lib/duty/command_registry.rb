require 'duty/commands/base'

module Duty
  module CommandRegistry
    COMMAND_NAMESPACE = Duty::Commands

    class << self
      attr_accessor :commands

      def all
        all_names = COMMAND_NAMESPACE.constants - [:Base]
        all_names.map do |name|
          COMMAND_NAMESPACE.const_get(name)
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
