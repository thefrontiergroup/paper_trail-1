$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "paper_trail/version_number"

Gem::Specification.new do |s|
  s.name = "paper_trail"
  s.version = PaperTrail::VERSION::STRING.dup # The `dup` is for ruby 1.9.3
  s.platform = Gem::Platform::RUBY
  s.summary = "Track changes to your models' data. Good for auditing or versioning."
  s.description = s.summary
  s.homepage = "https://github.com/airblade/paper_trail"
  s.authors = ["Andy Stewart", "Ben Atkins"]
  s.email = "batkinz@gmail.com"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version = ">= 1.9.3"

  s.add_dependency "activerecord", [">= 3.0", "< 6.0"]
  s.add_dependency "request_store", "~> 1.1"

  s.add_development_dependency "appraisal", "~> 2.1"
  s.add_development_dependency "rake", "~> 10.4.2"
  s.add_development_dependency "shoulda", "~> 3.5.0"
  s.add_development_dependency "ffaker", "~> 2.1.0"
  s.add_development_dependency "railties", [">= 3.0", "< 6.0"]
  s.add_development_dependency "rack-test", "~> 0.6.3"
  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "generator_spec", "~> 0.9.3"
  s.add_development_dependency "database_cleaner", "~> 1.2"
  s.add_development_dependency "pry-nav", "~> 0.2.4"
  s.add_development_dependency "rubocop", "~> 0.41.1"
  s.add_development_dependency "timecop", "~> 0.8.0"

  if defined?(JRUBY_VERSION)
    s.add_development_dependency "activerecord-jdbcsqlite3-adapter", "~> 1.3.15"
    s.add_development_dependency "activerecord-jdbcpostgresql-adapter", "~> 1.3.15"
    s.add_development_dependency "activerecord-jdbcmysql-adapter", "~> 1.3.15"
  else
    s.add_development_dependency "sqlite3", "~> 1.2"
    s.add_development_dependency "pg", "~> 0.17"

    # activerecord >= 4.2.5 may use mysql2 >= 0.4
    s.add_development_dependency "mysql2", "~> 0.4.2"
  end
end
