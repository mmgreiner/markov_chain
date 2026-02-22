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


task default: :test
