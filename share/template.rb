# Add the engine being tested to the app.
gem ENV['ENGINE_NAME'], :path => ENV['ENGINE_PATH']

# All development dependencies of the engine should be added to the app
# as they might be used in testing.
for dep in ENV['DEV_DEPS'].split(',')
  name, requirement = *dep.split('|', 2)
  gem name, requirement
end

# So you can see backtraces in your engine
append_file 'config/initializers/backtrace_silencers.rb', <<SILENCE
  Rails.backtrace_cleaner.add_filter {|line| line.sub "#{ENV['ENGINE_PATH']}/", '' }
SILENCE
