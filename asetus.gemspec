Gem::Specification.new do |s|
  s.name              = 'asetus'
  s.version           = '0.4.0'
  s.licenses          = ['Apache-2.0']
  s.platform          = Gem::Platform::RUBY
  s.authors           = ['Saku Ytti']
  s.email             = %w[saku@ytti.fi]
  s.homepage          = 'http://github.com/ytti/asetus'
  s.summary           = 'configuration library'
  s.description       = 'configuration library with object access to YAML/JSON/TOML backends'
  s.files             = %x(git ls-files -z).split("\x0")
  s.executables       = %w[]
  s.require_path      = 'lib'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.required_ruby_version = '>= 2.7'

  s.add_development_dependency 'bundler',             '~> 2.2'
  s.add_development_dependency 'rake',                '~> 13.0'
  s.add_development_dependency 'rubocop',             '~> 1.48.0'
  s.add_development_dependency 'rubocop-minitest',    '~> 0.34.2'
  s.add_development_dependency 'rubocop-rake',        '~> 0.6.0'
  s.add_development_dependency 'simplecov',           '~> 0.22.0'
  s.add_development_dependency 'simplecov-cobertura', '~> 2.1.0'
  s.add_development_dependency 'simplecov-html',      '~> 0.12.3'
end
