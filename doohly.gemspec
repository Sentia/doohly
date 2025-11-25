# frozen_string_literal: true

require_relative "lib/doohly/version"

Gem::Specification.new do |spec|
  spec.name = "doohly"
  spec.version = Doohly::VERSION
  spec.authors = ["Sentia"]
  spec.email = ["developer@sentia.com.au"]

  spec.summary = "Ruby client for the Doohly DOOH advertising platform API"
  spec.description = "A Ruby client library for interacting with the Doohly (Digital Out-of-Home) " \
                     "advertising platform API. Supports managing bookings, devices, creatives, and more."
  spec.homepage = "https://www.sentia.com.au"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Sentia/doohly"
  spec.metadata["changelog_uri"] = "https://github.com/Sentia/doohly/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/Sentia/doohly/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/doohly"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile docs/ examples/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-multipart", "~> 1.0"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rspec", "~> 2.20"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "webmock", "~> 3.18"
end
