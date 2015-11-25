require 'duty/tasks'
require 'yaml'

module Duty
  module Plugins
    def self.load(filename)
      if File.exists?(filename)
        duty_config = YAML.load(File.read(filename))
        tasks = duty_config["tasks"]
        tasks.map do |namespace, task_dir|
          Plugin.new(namespace, task_dir) if Dir.exists?(task_dir)
        end
      end
    end

    class Plugin
      TASK_NAMESPACE = Duty::Tasks
      def initialize(namespace, task_dir)
        @namespace = namespace
        @task_dir = task_dir
      end

      def namespace
        @namespace
      end

      def require_tasks
        task_files = File.expand_path(File.join(@task_dir, "*.rb"))
        Dir[task_files].each do |path|
          require path.gsub(/(\.rb)$/, '')
        end
      end

      def tasks
        task_names = TASK_NAMESPACE.constants - [:Base]
        task_names.reduce([]) do |task_classes, task_name|
          task_class = TASK_NAMESPACE.const_get(task_name)
          task_classes << task_class if valid?(task_class)
          task_classes
        end
      end

      private

      def valid?(task_class)
        task_class.superclass == TASK_NAMESPACE::Base
      end
    end
  end
end
