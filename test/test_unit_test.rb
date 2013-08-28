require_relative 'test_helper'
require 'test_engine/test_unit'

class TestUnitTest < TestCase

  # Do we correctly install the Test::Unit tasks?
  def test_install_tasks
    assert_equal [], Rake::Task.tasks
    TestEngine.install_tasks
    assert_equal %w(test:units test:functionals test:integration),
      %w(test:units test:functionals test:integration) &
      Rake::Task.tasks.collect(&:name)
  end

end
