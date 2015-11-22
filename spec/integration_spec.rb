require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a command' do
    it 'explains how to use the executable' do
      assert_stdout /Usage: duty <command> \[<args>\]\s{1}/ do
        exec(duty)
      end
    end

    it 'lists all available commands' do
      assert_stdout /Commands:/ do
        exec(duty)
      end

      assert_stdout /test\s*This is a test command/ do
        exec(duty)
      end
    end
  end

  describe 'with unknown command' do
    it 'explains that the given command is invalid' do
      assert_stdout /duty: `foo bar` is not a duty command/ do
        exec("#{duty} foo bar")
      end
    end
  end

  describe 'with --cmplt for shell completion' do
    it 'returns all commands without input' do
      assert_stdout /test/ do
        exec("#{duty} --cmplt")
      end
    end

    it 'returns matching commands with input' do
      assert_stdout /test/ do
        exec("#{duty} --cmplt t")
      end
    end
  end

  describe 'with known command' do
    describe 'test' do
      describe 'invalid usage' do
        it 'describes the command' do
          assert_stdout /This is a test command\s{1}/ do
            exec("#{duty} test")
          end
        end

        it 'explains how to use the command' do
          assert_stdout /Usage: duty test \[<args>\]\s{1}/ do
            exec("#{duty} test")
          end
        end
      end

      describe 'valid usage' do
        describe 'with shell commands' do
          it 'stops execution as soon as one command fails' do
            assert_stdout /#{check_mark} First shell command/ do
              exec("#{duty} test shell")
            end

            assert_stderr /#{cross_mark} Second shell command/ do
              exec("#{duty} test shell")
            end

            refute_stdout /Third shell command/ do
              exec("#{duty} test shell")
            end

            refute_stderr /Third shell command/ do
              exec("#{duty} test shell")
            end
          end
        end

        describe 'with ruby commands' do
          it 'stops execution as soon as one command fails' do
            assert_stdout /#{check_mark} First ruby command/ do
              exec("#{duty} test ruby")
            end

            assert_stderr /#{cross_mark} Second ruby command/ do
              exec("#{duty} test ruby")
            end

            refute_stdout /Third shell ruby/ do
              exec("#{duty} test ruby")
            end

            refute_stderr /Third shell ruby/ do
              exec("#{duty} test ruby")
            end
          end
        end
      end
    end
  end

  private

  def duty
    File.expand_path("../../bin/duty", __FILE__)
  end

  def duty_file
    '.duty.yml'
  end

  def check_mark
    "\u2713".encode('utf-8')
  end

  def cross_mark
    "\u2715".encode('utf-8')
  end

  def assert_stdout(expected, &command)
    stdout, stderr, status = yield command
    unless status.success?
      assert_equal 0, status.exitstatus, stderr
    end
    assert_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
  end

  def refute_stdout(expected, &command)
    stdout, _, _ = yield command
    refute_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
  end

  def assert_stderr(expected, &command)
    stdout, stderr, status = yield command
    unless status.success?
      assert_equal 0, status.exitstatus, stderr
    end
    assert_match expected, stderr, "Expected stdout to be #{expected} but got #{stderr}"
  end

  def refute_stderr(expected, &command)
    _, stderr, _ = yield command
    refute_match expected, stderr, "Expected stdout to be #{expected} but got #{stderr}"
  end

  def exec(*commands)
    duty_config = "commands: #{__dir__}/support"
    Dir.mktmpdir do |dir|
      commands.each do |command|
        @last_command = capture(command, :chdir => dir, :duty_config => duty_config)
      end
      @last_command
    end
  end

  def capture(command, options = {})
    if duty_config = options.delete(:duty_config)
      Open3.capture3("echo '#{duty_config}' > #{duty_file}", options)
    end

    stdout, stderr, status = Open3.capture3(command, options)
  end
end
