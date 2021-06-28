# frozen_string_literal: true

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'doger/version'

Gem::Specification.new do |spec|
  spec.name                   = 'doger'
  spec.version                = Doger::VERSION::STRING
  spec.authors                = ['David Chang']
  spec.email                  = 'david.chang.personal@gmail.com'
  spec.homepage               = 'https://github.com/lightningbolt/doger'
  spec.summary                = 'Doge Meme Generator'
  spec.description            = <<-DESC
  DESC

  spec.files                  = Dir['CHANGELOG.md', 'README.md', 'lib/**/*']
  spec.require_path           = 'lib'

  spec.required_ruby_version  = '>= 2.4.0'

  spec.add_dependency             'mini_magick',         '~> 4.11'

  spec.add_development_dependency 'minitest',            '~> 5.14'
  spec.add_development_dependency 'minitest-reporters',  '~> 1.4'
  spec.add_development_dependency 'rake',                '~> 13.0'
  spec.add_development_dependency 'rubocop',             '~> 1.10'
  spec.add_development_dependency 'rubocop-performance', '~> 1.9'
  spec.add_development_dependency 'yard',                '~> 0.9'
end
