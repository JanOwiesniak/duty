require 'minitest/autorun'
require "duty/config_loader"

class ConfigLoaderSpec < MiniTest::Spec
  describe 'config loader' do
    it 'loads config from base directory' do
      loader = Duty::ConfigLoader.new
      with_dir do |dir|
        write_config_file!(dir)
        assert_config(loader.load(dir))
      end
    end

    it 'loads config ascending until first config' do
      with_dir do |root_dir|
        full_depth = File.join(root_dir, "level1", "level2", "level3")
        FileUtils.mkdir_p(full_depth)
        loader     = Duty::ConfigLoader.new(root_dir)

        write_config_file!(root_dir, '')
        write_config_file!(File.join(root_dir, "level1", "level2"))
        assert_config loader.load(full_depth)
      end
    end

    it 'loads config ascending until configured root' do
      with_dir do |dir|
        root_dir   = File.join(dir, "level1")
        full_depth = File.join(dir, "level1", "level2", "level3")
        loader     = Duty::ConfigLoader.new(root_dir)
        FileUtils.mkdir_p(full_depth)
        write_config_file!(dir)
        config = loader.load(full_depth)
        assert config["tasks"].empty?, "should not have the tasks loaded"
      end
    end

    private

    def assert_config(config)
      assert_equal config_expected, config
    end

    def with_dir(&block)
      Dir.mktmpdir(&block)
    end

    def write_config_file!(dir, config = config_fixture)
      path = File.join(dir, config_filename)
      File.write(path, config_fixture)
    end

    def config_filename
      Duty::ConfigLoader::DUTY_CONFIG_FILENAME
    end

    def config_fixture
      "tasks:\n  test: foo/bar/some_plugin.rb"
    end

    def config_expected
      { 'tasks' => { 'test' => 'foo/bar/some_plugin.rb' } }
    end
  end
end
