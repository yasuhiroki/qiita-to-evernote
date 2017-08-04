# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "qiita2evernote/version"

Gem::Specification.new do |spec|
  spec.name          = "qiita2evernote"
  spec.version       = Qiita2Evernote::VERSION
  spec.authors       = ["yasuhiroki"]
  spec.email         = ["yasuhiroki.duck@gmail.com"]

  spec.summary       = %q{Transfer your qiita stocks to your evernote notebook}
  spec.description   = %q{Transfer your qiita stocks to your evernote notebook}
  spec.homepage      = "https://github.com/yasuhiroki/qiita-to-evernote"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "dotenv", "~> 2.2"
  spec.add_dependency "evernote-thrift", "~> 1.25"
  spec.add_dependency "h2e-rb", "~> 0.1"
  spec.add_dependency "qiita", "~> 1.3"
  spec.add_dependency "qiita-markdown", "~> 0.20"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
