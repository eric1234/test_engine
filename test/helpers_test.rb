require_relative 'test_helper'
require 'test_engine/engine_helper'

# Test the various helper methods defined in the library that are mostly used
# for internal purposes. There are two issues with these test:
#
#   * We have a little bit of a chicken and egg setup. These helper methods
#     are used to implement other testing. So testing them now is a bit too
#     late. But better test late than never.
#   * The path and Rails version methods cannot really be tested without making
#     the tests just as complicated as what we are testing. We could hard-code
#     the versions and paths but that will change machine to machine.
class HelpersTest < TestCase
  include TestEngine::EngineHelper

  def test_clean_sh
    assert_equal "Rails #{older_installed_rails}\n",
      clean_sh("#{rails_stub} _#{older_installed_rails}_ -v")

    # FIXME: Figure out how to test clean_sh with full_io enabled.
  end

  def test_rake
    TestEngine.install_tasks
    Rake::Task['test:engine:generate'].invoke
    assert_match /^About your application/, rake('about')
  end

  def test_engine_name
    assert_equal 'test_engine', engine_name
  end

  def test_development_dependencies
    assert_equal ['rake'], development_dependencies
  end

end
