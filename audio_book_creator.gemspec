# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'audio_book_creator/version'

Gem::Specification.new do |spec|
  spec.name          = "audio_book_creator"
  spec.version       = AudioBookCreator::VERSION
  spec.authors       = ["Keenan Brock"]
  spec.email         = ["keenan@thebrocks.net"]
  spec.summary       = %q{Create an audiobook from a url}
  spec.description   = %q{This takes html files and creates a chapterized audiobook.
  It leverages Apple's speak command and audio book binder}
  spec.homepage      = "http://github.com/kbrock/audio_book_creator"
  spec.license       = "MIT"

  spec.bindir        = 'exe'
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sqlite3"
  spec.add_runtime_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codeclimate-test-reporter"
end
