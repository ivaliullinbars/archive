require "bundler/gem_tasks"
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_*.rb"]
  t.verbose = true
end

RDoc::Task.new do |rdoc|
  rdoc.title = "Simple library to manage tar and zip archives with libarchive and FFI"
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
  rdoc.rdoc_files -= ["lib/archive/version.rb"]
  if ENV["RDOC_COVER"]
    rdoc.options << "-C"
  end
end

desc "run tests with coverage report"
task "test:coverage" do
  ENV["COVERAGE"] = "1"
  Rake::Task["test"].invoke
end

desc "run rdoc with coverage report"
task :rdoc_cov do
  # ugh
  ENV["RDOC_COVER"] = "1"
  ruby "-S rake rerdoc"
end
