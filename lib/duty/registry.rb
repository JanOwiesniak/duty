require 'duty/tasks'

module Duty
  class Registry
    COMMAND_NAMESPACE = Duty::Tasks

    def initialize(additional_tasks_dir = nil)
      @core_tasks_dir = __dir__
      @additional_tasks_dir = additional_tasks_dir
    end

    def all
      task_names = COMMAND_NAMESPACE.constants - [:Base]
      task_names.reduce([]) do |task_classes, task_name|
        task_class = COMMAND_NAMESPACE.const_get(task_name)
        task_classes << task_class if valid?(task_class)
        task_classes
      end
    end

    def valid?(task_class)
      task_class.superclass == Duty::Tasks::Base
    end

    def require_all
      require_tasks(@core_tasks_dir)
      require_tasks(@additional_tasks_dir) if @additional_tasks_dir
    end

    def require_tasks(dir)
      task_files =File.expand_path(File.join(dir, "*.rb"))
      Dir[task_files].each do |path|
        require path.gsub(/(\.rb)$/, '')
      end
    end
  end
end
