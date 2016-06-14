# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sendgrid_api/version"

Gem::Specification.new do |s|
  s.name        = "sendgrid_api"
  s.version     = SendgridApi::VERSION
  s.authors     = ["Mark Edmondson"]
  s.email       = ["mark@guestfolio.com"]
  s.homepage    = ""
  s.summary     = %q{Integration with SendGrid Web API}
  s.description = %q{}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.has_rdoc = true

  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
  s.add_development_dependency "ruby-prof"
  s.add_development_dependency "appraisal"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-byebug"

  s.add_runtime_dependency "mail"
  s.add_runtime_dependency "faraday_middleware"
end
