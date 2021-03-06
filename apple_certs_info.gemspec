require_relative 'lib/apple_certs_info/version'

Gem::Specification.new do |spec|
  spec.name          = "apple_certs_info"
  spec.version       = AppleCertsInfo::VERSION
  spec.authors       = ["tarappo"]
  spec.email         = ["tarappo@gmail.com"]

  spec.summary       = %q{Apple Certificate files and Provisioning Profile information.}
  spec.homepage      = "https://github.com/tarappo/apple_certs_info"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tarappo/apple_certs_info"
  spec.metadata["changelog_uri"] = "https://github.com/tarappo/apple_certs_info/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
