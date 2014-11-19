Gem::Specification.new do |s|
  s.version = '0.0.1'
  b.name = "hiera-yamlerb"
  s.email = "erik.gustav.dalen@gmail.com"
  s.authors = "Erik Dalen"
  s.summary = "A YAML backend with ERB templating for Hiera."
  s.description = "Allows YAML hiera files to be templated using ERB."
  s.has_rdoc = false
  s.homepage = "http://github.com/dalen/hiera-yamlerb"
  s.license = "Apache 2.0"
  s.files = Dir["lib/**/*.rb"]
  s.files += ["LICENSE"]

  s.add_dependency 'hiera', '~> 1.3'

  s.add_development_dependency 'rspec', '~> 2.11.0'
  s.add_development_dependency 'mocha', '~> 0.10.5'
end
