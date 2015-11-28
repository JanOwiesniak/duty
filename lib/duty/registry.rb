module Duty
  class Registry
    def self.register(plugins = [])
      new(plugins).tap {|registry| registry.load_tasks }
    end

    attr_reader :plugins
    def initialize(plugins)
      @plugins = plugins
    end

    def load_tasks
      plugins.each {|plugin| plugin.load_tasks }
    end
  end
end
