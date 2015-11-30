require 'duty/tasks'
require 'yaml'

module Duty
  module Plugins
    def self.load(config)
      Duty::Plugins::List.new.tap do |list|
        config["tasks"].each do |namespace, plugin_entry_point|
          list << Plugin.new(namespace, plugin_entry_point)
        end
      end
    end

    class List
      require 'forwardable'
      include Enumerable
      extend Forwardable
      def_delegators :@plugins, :each, :<<
      def initialize
        @plugins = []
      end
    end

    class Plugin
      def initialize(namespace, entry)
        @namespace = namespace
        @entry = entry
        @tasks = []
      end

      def namespace
        @namespace
      end

      def tasks
        @task_classes.select do |task_class|
          valid?(task_class)
        end
      end

      def load_tasks
        require_tasks
        expose_tasks
      end

      private

      def require_tasks
        path = @entry.gsub(/\.rb/,'')
        require path
      end

      def expose_tasks
        @task_classes = eval(File.read(@entry)).tasks
      end

      private

      def valid?(task_class)
        task_class.ancestors.include? ::Duty::Tasks::Base
      end
    end
  end
end
