# coding: utf-8

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name     = 'spree_simple_volume_pricing'
  s.version  = '2.0.0'
  s.summary  = 'Adds volume pricing capabilities to Spree'

  s.author   = 'Adam Wróbel'
  s.email    = 'adam@adamwrobel.com'

  s.files        = Dir['README.md', 'LICENSE', 'lib/**/*', 'app/**/*',
                       'db/**/*', 'config/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.required_ruby_version = '>= 1.8.7'

  s.add_dependency('spree_core', '>= 0.40.3')
  s.add_dependency('render_inheritable', '>= 1.0.0')
end
