Gem::Specification.new do |s|
  s.name              = 'asetus'
  s.version           = '0.0.7'
  s.platform          = Gem::Platform::RUBY
  s.authors           = [ 'Saku Ytti' ]
  s.email             = %w( saku@ytti.fi )
  s.homepage          = 'http://github.com/ytti/asetus'
  s.summary           = 'configuration library'
  s.description       = 'configuration library with object access to YAML/JSON/CSON backends'
  s.rubyforge_project = s.name
  s.files             = `git ls-files`.split("\n")
  s.executables       = %w(  )
  s.require_path      = 'lib'

  s.add_dependency 'slop'
end
