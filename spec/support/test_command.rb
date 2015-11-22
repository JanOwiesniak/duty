module Duty
  module Commands
    module Test
      def shell_commands(test_type)
        sh {}
        sh("First #{test_type} shell command") { 'pwd' }
        sh("Second #{test_type} shell command") { 'boom' }
        sh("Third #{test_type} shell command") { 'pwd' }
      end

      def ruby_commands(test_type)
        ruby {}
        ruby("First #{test_type} ruby command") {}
        ruby("Second #{test_type} ruby command") { raise RuntimeError.new }
        ruby("Third #{test_type} ruby command") {}
      end
    end
  end
end

module Duty
  module Tasks
    class Test < Base
      include Duty::Commands::Test

      def execute
        if sequential? 
          shell_commands(test_type) if shell?
          ruby_commands(test_type) if ruby?
        end

        if parallel? 
          parallel { shell_commands(test_type) }
          parallel { ruby_commands(test_type) }
        end
      end

      def valid?
        !!test_type
      end

      private

      def sequential?
        test_type == 'sequential'
      end

      def parallel?
        test_type == 'parallel'
      end

      def test_type
        @arguments[0]
      end

      def ruby?
        test_command == 'ruby'
      end

      def shell?
        test_command == 'shell'
      end

      def test_command
        @arguments[1]
      end
    end
  end
end
