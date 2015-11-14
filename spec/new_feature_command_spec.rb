require "minitest/autorun"
require 'duty'

class NewFeatureCommandsSpec < MiniTest::Spec
  describe 'new-feature' do
    it 'is valid with a given branch name' do
      refute Duty::Commands::NewFeature.new.valid?
      assert Duty::Commands::NewFeature.new('branch-name').valid?
    end

    it 'knows how it should be used' do
      expected = /Creates a new feature branch\s*Usage: duty new-feature <name>/
      explanation = Duty::Commands::NewFeature.new.usage
      assert_match expected, explanation
    end

    describe 'without name' do
      it 'does not execute any commands' do
        system = fake_system
        executer = Duty::Commands::NewFeature.new.call(system)
        assert_equal [], system.calls
        assert_equal [], executer.executed
      end
    end

    describe 'with name' do
      describe 'on success system' do
        it 'successfully executes all 3 commands in a row' do
          system = success_system
          executer = Duty::Commands::NewFeature.new('awesome').call(system)

          assert_equal 3, system.calls.size
          assert_equal 'git checkout master', system.calls[0]
          assert_equal "git checkout -b 'feature/awesome'", system.calls[1]
          assert_equal "git push -u origin 'feature/awesome'", system.calls[2]

          executer.executed.each do |command|
            assert_equal true, command.executed?
            assert_equal false, command.error?, command.error
            assert_equal nil, command.error
          end
        end
      end

      describe 'on fail system' do
        it 'executes all 3 commands in a row and knows what went wrong' do
          system = fail_system
          executer = Duty::Commands::NewFeature.new('awesome').call(system)

          assert_equal 3, system.calls.size
          assert_equal 'git checkout master', system.calls[0]
          assert_equal "git checkout -b 'feature/awesome'", system.calls[1]
          assert_equal "git push -u origin 'feature/awesome'", system.calls[2]

          executer.executed.each do |command|
            assert_equal true, command.executed?
            assert_equal true, command.error?, command.error
            assert_equal 'something went wrong', command.error
          end
        end
      end

      describe 'commands' do
        describe 'checkout `master` branch' do
          it 'successfully checks out the `master` branch' do
            system = success_system
            executer = Duty::Commands::NewFeature.new('awesome').call(system)

            command = executer.executed[0]
            assert_equal 'git checkout master', command.cmd
            assert_match /duty/, command.pwd
            assert_equal 'Checkout `master` branch', command.describe
          end
        end

        describe 'create feature branch' do
          it 'successfully checks out the new feature branch' do
            system = success_system
            executer = Duty::Commands::NewFeature.new('awesome').call(system)

            command = executer.executed[1]
            assert_equal "git checkout -b 'feature/awesome'", command.cmd
            assert_match /duty/, command.pwd
            assert_equal 'Checkout `feature/awesome` branch', command.describe
          end
        end

        describe 'push feature branch to origin' do
          it 'successfully pushs the new feature branch to origin' do
            system = success_system
            executer = Duty::Commands::NewFeature.new('awesome').call(system)

            command = executer.executed[2]
            assert_equal "git push -u origin 'feature/awesome'", command.cmd
            assert_match /duty/, command.pwd
            assert_equal 'Push `feature/awesome` branch to `origin`', command.describe
          end
        end
      end
    end
  end

  private

  def fake_system
    FakeSystem.new
  end

  def success_system
    SuccessSystem.new
  end

  def fail_system
    FailSystem.new
  end

  class FakeSystem
    def initialize
      @calls = []
    end

    def call(_)
    end

    def calls
      @calls
    end
  end

  class FailSystem < FakeSystem
    def call(cmd)
      @calls << cmd
      stdout = nil
      stderr = 'something went wrong'
      status = -1
      [stdout, stderr, status]
    end
  end

  class SuccessSystem < FakeSystem
    def call(cmd)
      @calls << cmd
      stdout = nil
      stderr = nil
      status = 0
      [stdout, stderr, status]
    end
  end
end
