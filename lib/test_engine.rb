require 'pathname'
require 'rake/tasklib'
require 'bundler'

# Just to define namespace
class TestEngine < Rake::TaskLib; end

# Both the library and the tests use most of these helper functions so putting
# them in a public module but they are not really intended for external use.
require 'test_engine/system_helper'
require 'test_engine/rake_helper'
require 'test_engine/engine_helper'

# A rake tasklib that will handle installing all relevant tasks.
class TestEngine < Rake::TaskLib
  include Singleton
  include TestEngine::SystemHelper
  include TestEngine::RakeHelper
  include TestEngine::EngineHelper

  # Define the "generate" task which will generate a dummy Rails app when ran.
  def install_generate
    task 'test:engine:generate' do
      unless app_path.exist?

        # Some info for the app template
        env = {
          'ENGINE_NAME' => engine_name,
          'ENGINE_PATH' => Dir.pwd,
          'DEV_DEPS'    => (development_dependencies - ['test_engine']).join(','),
        }

        clean_sh %Q!
            #{rails_stub} _#{rails_version}_ new #{app_path}
              --skip-bundle -f -m #{template_path}
          !, env
      end
    end
  end

  # Define the "setup" task that will load any engine migrations and seed data
  def install_setup
    task 'test:engine:setup' => 'test:engine:generate' do
      unless app_path.join('db/schema.rb').exist?
        clean_sh 'bundle install --quiet', {'BUNDLE_GEMFILE' => gemfile_path}, true
        rake "railties:install:migrations"
        rake "db:migrate", 'RAILS_ENV' => 'test'
      end
    end
  end

  # Define "env" task which will cause the Rails app to be loaded in subprocess.
  def install_env
    task 'test:engine:env' => 'test:engine:setup' do
      ENV['BUNDLE_GEMFILE'] = gemfile_path.to_s
      ENV['RUBYOPT'] = "-r./#{app_path}/config/environment"
      ENV['RAILS_ENV'] = 'test'
    end
  end

  # Define the "clean" task which will remove dummy Rails apps when ran.
  def install_clean
    desc 'Remove dummy test apps. RAILS_VERSION to remove specific version'
    task 'test:engine:clean' do
      rails_version = ENV['RAILS_VERSION'] || '*'
      rm_rf Dir["tmp/dummy_apps/v#{rails_version}"], :verbose => false
    end
  end

  # So user can refer to 'test:engine' instead of 'test:engine:generate'.
  # NOTE: This method MUST be later alphabetically than install_generate.
  def install_shortcut
    task 'test:engine' => 'test:engine:env'
  end

  class << self

    # Will call all instance methods that start with "install_" (alphabetical).
    # This will allow new tasks to be pulled in easily depending on the framework
    # being used (currently only TestUnit).
    def install_tasks
      install_methods.each {|meth| instance.send(meth)}
    end

    private

    def install_methods
      instance_methods(false).find_all {|m| m.to_s =~ /^install_/}
    end
  end

end
