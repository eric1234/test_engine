require 'test_engine'
require 'rake/testtask'

# Add tasks designed to mimic what Rails provides for Test::Unit by default
class TestEngine < Rake::TaskLib

  def install_test_unit_unit
    test_unit_task 'test:units', 'test/unit/**/*_test.rb'
  end

  def install_test_unit_functional
    test_unit_task 'test:functionals', 'test/functional/**/*_test.rb'
  end

  def install_test_unit_integration
    test_unit_task 'test:integration', 'test/integration/**/*_test.rb'
  end

  def install_test_unit_shortcut
    desc 'Run all tests'
    task :test => ['test:units', 'test:functionals', 'test:integration']
  end

  private

  def test_unit_task(task_name, pattern)
    Rake::TestTask.new(task_name => 'test:engine') do |t|
      t.libs << 'test'
      t.pattern = pattern
    end
  end

end

TestEngine.install_tasks