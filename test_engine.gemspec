Gem::Specification.new do |s|
  s.name = 'test_engine'
  s.version = '0.0.1'
  s.author = 'Eric Anderson'
  s.email = 'eric@pixelwareinc.com'
  s.add_dependency 'rails', '> 3'
  s.add_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = true
  s.extra_rdoc_files << 'README.rdoc'
  s.rdoc_options << '--main' << 'README.rdoc'
  s.summary = 'Easy testing of Rails engines'
  s.description = <<-DESCRIPTION
    Allows you to easily implement testing for a Rails engine and have it
    execute in the context of a dummy test app.
  DESCRIPTION
end
