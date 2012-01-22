# Module to gather information about the engine being tested
module TestEngine::EngineHelper

  # The name of the engine being tested
  def engine_name
    gemspec_path.basename('.gemspec').to_s
  end

  # A list of all development dependencies defined by the engine's gemspec
  def development_dependencies
    Gem::Specification.load(gemspec_path.to_s).development_dependencies.collect &:name
  end

  private

  # The path to the gemspec for the engine being tested.
  def gemspec_path
    Pathname.glob('*.gemspec').first
  end

end