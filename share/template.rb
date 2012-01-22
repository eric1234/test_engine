# Add the engine being tested to the app.
gem ENV['ENGINE_NAME'], :path => ENV['OLDPWD']

# All development dependencies of the engine should be added to the app
# as they might be used in testing.
for dep in ENV['DEV_DEPS'].split(',')
  gem dep
end