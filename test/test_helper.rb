require 'minitest/autorun'
require 'fileutils'
require 'test_engine'

class TestCase < Minitest::Unit::TestCase
  include TestEngine::RakeHelper
  include TestEngine::SystemHelper

  def assert_file_exists(file)
    assert File.exists?(file.to_s), "#{file} does not exist"
  end

  def assert_file_contents_match(file, pattern)
    assert_match pattern, File.read(file.to_s)
  end

  def setup
    Rake::Task.clear
    remove_apps
    ENV.delete 'RAILS_VERSION'
  end

  def teardown
    remove_apps
  end

  private

  def remove_apps
    FileUtils.rm_rf library_path.join('tmp').to_s
  end

end
