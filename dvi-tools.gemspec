# frozen_string_literal: true

require_relative 'lib/dvi_tools/version'

Gem::Specification.new do |spec|
  spec.name = 'dvi-tools'
  spec.version = DviTools::VERSION
  spec.authors = ['Your Name']
  spec.email = ['your.email@example.com']

  spec.summary = 'A Ruby toolkit for analyzing and comparing TeX DVI files'
  spec.description = 'DVI Tools provides functionality to parse, analyze, and compare TeX DVI files, helping identify differences in LaTeX build outputs.'
  spec.homepage = 'https://github.com/yourusername/dvi-tools'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 1.3'

  spec.add_development_dependency 'colorize', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.66'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.1'
end
