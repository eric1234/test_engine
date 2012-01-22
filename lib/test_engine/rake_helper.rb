# Methods used by this library (and tests) to keep rake tasks simpler
module TestEngine::RakeHelper

  # Will run the given rake command on the app in a clean environment
  def rake(command, env={})
    clean_sh "rake -f #{app_path}/Rakefile #{command}", env
  end

  # Like "sh" but with the following changes:
  #
  # * Run in Bundler.with_clean_env
  # * Automatically :verbose => false
  # * Environment can be passed in as an option (set after cleaned)
  # * command is auto compacted (whitespace turns into simple space)
  # * Values in env are automatically converted to a string
  #
  # If full_io is set then the command executing will have full ability to
  # interact with the user. If false then the output is simply returned.
  def clean_sh(command, env={}, full_io=false)
    command.gsub! /\s+/, ' '
    Bundler.with_clean_env do
      # Until https://github.com/carlhuda/bundler/issues/1604 released
      # Once released remove this line and add version dependency to gemspec
      ENV['RUBYOPT'] = ENV['RUBYOPT'].sub '-rbundler/setup', '' if ENV.has_key? 'RUBYOPT'

      env.each {|k,v| ENV[k] = v.to_s}
      if full_io
        system command
      else
        `#{command}`
      end
    end
  end

end