# frozen_string_literal: true

require_relative 'lib/mquve/version'

Gem::Specification.new do |spec|
  spec.name = 'mquve'
  spec.version = Mquve::VERSION
  spec.authors = ['Moeki Kawakami']

  spec.summary = 'Pure Ruby node-based markdown parser'
  spec.description = 'Pure Ruby node-based markdown parser'
  spec.homepage = 'https://github.com/kawakamimoeki/mquve'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kawakamimoeki/mquve'
  spec.metadata['changelog_uri'] = 'https://github.com/kawakamimoeki/mquve/blob/main/CHANGELOG.md'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
