module Duty
  class Registry
    def self.instance
      return @instance if @instance
      @instance = new
    end

    def self.register(plugin_class)
      instance.send(:plugins) << Plugin.new(plugin_class)
    end

    def plugins
      @plugins
    end

    private

    class Plugin
      attr_reader :namespace, :tasks
      def initialize(plugin_class)
        @namespace = plugin_class.namespace
        @tasks = plugin_class.tasks
      end
    end

    def initialize
      @plugins = []
    end
  end
end
