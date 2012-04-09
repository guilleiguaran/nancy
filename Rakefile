#!/usr/bin/env rake
require 'rake/testtask'

task :test do
  Dir.chdir('test')
end

Rake::TestTask.new(:test) do |t|
  t.libs << '../lib'
  t.libs << '../test'
  t.test_files = FileList['*_test.rb']
  t.verbose = false
end

task :default => :test
