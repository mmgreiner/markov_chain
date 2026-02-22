# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'standard/rake'
require "rake/testtask"

# task default: :standard

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

# Release to github only, not gem server
Rake::Task["release"].clear

desc "Build and tag without pushing to RubyGems"
task :release do
  gemspec = "markov_chain.gemspec"
  sh "gem build #{gemspec}"
  sh "git tag v#{Gem::Specification.load(gemspec).version}"
  sh "git push --tags"
end

task default: :test
