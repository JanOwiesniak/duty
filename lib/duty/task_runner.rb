module Duty
  class TaskRunner
    def initialize(view, input, plugins)
      @view = view
      @input = input
      @plugins = plugins
    end

    def self.run(view, input, plugins)
      self.new(view, input, plugins).run
    end

    def run
      task_class.new(task_input, view).run
    end

    private

    attr_reader :view

    def task_class
      name = task_name.split('-').collect(&:capitalize).join
      @plugins.each do |plugin|
        plugin.tasks.each do |task_class|
          if task_class.to_s.split("::").last == name
            @task_class = task_class
          end
        end
      end
      @task_class
    end

    def task_input
      @input.task_input
    end

    def task_name
      @input.task_name
    end
  end
end
