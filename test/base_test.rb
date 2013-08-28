require_relative 'test_helper'

class BaseTest < TestCase

  # Do we correctly install the base tasks?
  def test_install_tasks
    assert_equal [], Rake::Task.tasks
    TestEngine.install_tasks
    assert_equal \
      %w(test:engine test:engine:clean test:engine:env test:engine:generate test:engine:setup),
      %w(test:engine test:engine:clean test:engine:env test:engine:generate test:engine:setup) &
      Rake::Task.tasks.collect(&:name)
  end

  # Does it generate a Rails app for the latest version?
  def test_dummy_app_generated
    TestEngine.install_tasks
    Rake::Task['test:engine:generate'].invoke
    assert_file_exists app_path.join('config/application.rb')

    # Make sure our engine is a dependency of the new app using :path
    assert_file_contents_match app_path.join('Gemfile'), %Q{gem "test_engine", path: "#{library_path.expand_path}"}

    # Modify a file so we can verify the app is not regenerated
    modified_file = app_path.join('README').to_s
    open(modified_file, 'w+') {|f| f.write 'Modified'}

    Rake::Task['test:engine:generate'].reenable
    Rake::Task['test:engine:generate'].invoke
    assert_file_contents_match modified_file, "Modified"
  end

  # Can we specify a specific version.
  def test_generate_specific_version
    TestEngine.install_tasks
    ENV['RAILS_VERSION'] = older_installed_rails
    Rake::Task['test:engine:generate'].invoke
    assert_file_contents_match dummy_apps_path.join("v#{older_installed_rails}/Gemfile"), "'rails', '#{older_installed_rails}'"
  end

  # Can we zap all dummy apps?
  def test_clean_all
    TestEngine.install_tasks
    Rake::Task['test:engine:generate'].invoke
    ENV['RAILS_VERSION'] = older_installed_rails
    Rake::Task['test:engine:generate'].reenable
    Rake::Task['test:engine:generate'].invoke
    assert_equal 2, dummy_apps_path.children.size
    ENV['RAILS_VERSION'] = nil
    Rake::Task['test:engine:clean'].invoke
    assert_equal 0, dummy_apps_path.children.size
  end

  # Can we zap a specific dummy app?
  def test_clean_specific_version
    TestEngine.install_tasks
    Rake::Task['test:engine:generate'].invoke
    ENV['RAILS_VERSION'] = older_installed_rails
    Rake::Task['test:engine:generate'].reenable
    Rake::Task['test:engine:generate'].invoke
    assert_equal 2, dummy_apps_path.children.size
    Rake::Task['test:engine:clean'].invoke
    assert_equal 1, dummy_apps_path.children.size
  end

  # Is the database setup
  # QUESTION: Currently we are only testing if a database and schema file
  #           exists. Should we test that an actual migration runs
  #           correctly and is populated to the datbase?
  def test_setup
    TestEngine.install_tasks
    Rake::Task['test:engine:setup'].invoke
    assert app_path.join('db/schema.rb').exist?
    assert app_path.join('db/test.sqlite3').exist?
  end

  # Does sub-processes run in context of generated ruby app.
  def test_env
    TestEngine.install_tasks
    ENV['RAILS_VERSION'] = older_installed_rails
    Rake::Task['test:engine:env'].invoke
    # In case Bundler wants to force a Rails version on us
    ENV['RUBYOPT'] = ENV['RUBYOPT'].sub '-rbundler/setup', '' if ENV.has_key? 'RUBYOPT'
    assert_equal older_installed_rails, `ruby -e "puts Rails.version"`.chomp
  end

end
