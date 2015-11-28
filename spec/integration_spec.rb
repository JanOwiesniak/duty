require "minitest/autorun"
require "open3"

class IntegrationSpec < MiniTest::Spec
  describe 'without a task' do
    it 'explains how to use the executable' do
      assert_stdout /Usage: duty <task> \[<args>\]\s{1}/ do
        exec(duty)
      end
    end

    it 'lists all available tasks' do
      assert_stdout /Tasks:/ do
        exec(duty)
      end

      assert_stdout /test\s*TODO: Describe your task by overwriting `self\.description`/ do
        exec(duty)
      end
    end
  end

  describe 'with unknown task' do
    it 'explains that the given task is invalid' do
      assert_stdout /duty: `foo bar` is not a duty task/ do
        exec("#{duty} foo bar")
      end
    end
  end

  describe 'with --cmplt for shell completion' do
    it 'returns all tasks without input' do
      assert_stdout /test/ do
        exec("#{duty} --cmplt")
      end
    end

    it 'returns matching tasks with input' do
      assert_stdout /test/ do
        exec("#{duty} --cmplt t")
      end
    end
  end

  describe 'with known task' do
    describe 'test' do
      describe 'invalid usage' do
        it 'describes the task' do
          assert_stdout /TODO: Describe your task by overwriting `self.description`/ do
            exec("#{duty} test")
          end
        end

        it 'explains how to use the task' do
          assert_stdout /TODO: Explain your task by overwriting `self.usage`/ do
            exec("#{duty} test")
          end
        end
      end

      describe 'valid usage' do
        describe 'sequential' do
          describe 'with shell commands' do
            it 'runs commands in isolation' do
              assert_stdout /#{check_mark} Unknown shell command/ do
                exec("#{duty} test parallel")
              end

              assert_stdout /#{check_mark} First parallel shell command/ do
                exec("#{duty} test parallel")
              end

              assert_stderr /#{cross_mark} Second parallel shell command/ do
                exec("#{duty} test parallel")
              end

              assert_stderr /#{cross_mark} Test task aborted/ do
                exec("#{duty} test parallel")
              end

              refute_stdout /Third parallel shell command/ do
                exec("#{duty} test parallel")
              end

              refute_stderr /Third parallel shell command/ do
                exec("#{duty} test parallel")
              end

              assert_stdout /#{check_mark} Unknown ruby command/ do
                exec("#{duty} test parallel")
              end

              assert_stdout /#{check_mark} First parallel ruby command/ do
                exec("#{duty} test parallel")
              end

              assert_stderr /#{cross_mark} Second parallel ruby command/ do
                exec("#{duty} test parallel")
              end

              assert_stderr /#{cross_mark} Test task aborted/ do
                exec("#{duty} test parallel")
              end

              refute_stdout /Third parallel ruby command/ do
                exec("#{duty} test parallel")
              end

              refute_stderr /Third parallel ruby command/ do
                exec("#{duty} test parallel")
              end
            end
          end
        end

        describe 'sequential' do
          describe 'with shell commands' do
            it 'stops execution as soon as one task fails' do
              assert_stdout /#{check_mark} Unknown shell command/ do
                exec("#{duty} test sequential shell")
              end

              assert_stdout /#{check_mark} First sequential shell command/ do
                exec("#{duty} test sequential shell")
              end

              assert_stderr /#{cross_mark} Second sequential shell command/ do
                exec("#{duty} test sequential shell")
              end

              assert_stderr /#{cross_mark} Test task aborted/ do
                exec("#{duty} test sequential shell")
              end

              refute_stdout /Third sequential shell command/ do
                exec("#{duty} test sequential shell")
              end

              refute_stderr /Third sequential shell command/ do
                exec("#{duty} test sequential shell")
              end
            end
          end

          describe 'with ruby commands' do
            it 'stops execution as soon as one task fails' do
              assert_stdout /#{check_mark} Unknown ruby command/ do
                exec("#{duty} test sequential ruby")
              end

              assert_stdout /#{check_mark} First sequential ruby command/ do
                exec("#{duty} test sequential ruby")
              end

              assert_stderr /#{cross_mark} Second sequential ruby command/ do
                exec("#{duty} test sequential ruby")
              end

              assert_stderr /#{cross_mark} Test task aborted/ do
                exec("#{duty} test sequential ruby")
              end

              refute_stdout /Third sequential ruby command/ do
                exec("#{duty} test sequential ruby")
              end

              refute_stderr /Third sequential ruby command/ do
                exec("#{duty} test sequential ruby")
              end
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

  def assert_stdout(expected, &task)
    stdout, stderr, status = yield task
    unless status.success?
      assert_equal 0, status.exitstatus, stderr
    end
    assert_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
  end

  def refute_stdout(expected, &task)
    stdout, _, _ = yield task
    refute_match expected, stdout, "Expected stdout to be #{expected} but got #{stdout}"
  end

  def assert_stderr(expected, &task)
    stdout, stderr, status = yield task
    unless status.success?
      assert_equal 0, status.exitstatus, stderr
    end
    assert_match expected, stderr, "Expected stdout to be #{expected} but got #{stderr}"
  end

  def refute_stderr(expected, &task)
    _, stderr, _ = yield task
    refute_match expected, stderr, "Expected stdout to be #{expected} but got #{stderr}"
  end

  def exec(*tasks)
    duty_config = "tasks:\n  test: #{__dir__}/support/integration_test_plugin.rb"
    Dir.mktmpdir do |dir|
      tasks.each do |task|
        @last_task = capture(task, :chdir => dir, :duty_config => duty_config)
      end
      @last_task
    end
  end

  def capture(task, options = {})
    if duty_config = options.delete(:duty_config)
      Open3.capture3("echo '#{duty_config}' > #{duty_file}", options)
    end

    stdout, stderr, status = Open3.capture3(task, options)
  end
end
