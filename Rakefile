# A Rakefile defines tasks to help maintain your project.
# Rake provides several task templates that are useful.

# require "rspec/core/rake_task"
require "bump/tasks"
require "bundler/gem_tasks"

#------------------------------------------------------------------#
#                    Rake Default Task
#------------------------------------------------------------------#

# Do not run integration by default
task default: %I{test:unit test:functional}

#------------------------------------------------------------------#
#                    Test Runner Tasks
#------------------------------------------------------------------#
require "rake/testtask"

namespace :test do
  {
    unit: "test/unit/*_test.rb",
    functional: "test/integration/*_test.rb",
    integration: "test/function/*_test.rb",
  }.each do |task_name, glob|
    Rake::TestTask.new(task_name) do |t|
      t.libs.push "lib"
      t.libs.push "test"
      t.test_files = FileList[glob]
      t.verbose = true
      t.warning = false
    end
  end
end

#------------------------------------------------------------------#
#                    Code Style Tasks
#------------------------------------------------------------------#
require "chefstyle"
require "rubocop/rake_task"
RuboCop::RakeTask.new(:lint) do |task|
  task.options << "--display-cop-names"
end


require "guard"
require "guard/commander"

desc "Watch for source changes and redeploy Gem"
task :guard do
  Guard.start({ no_interactions: true })
  while ::Guard.running do
    sleep 0.5
  end
end

namespace :lint do
  desc 'Linting for all markdown files'
  task :markdown do
    require 'mdl'

    MarkdownLint.run(%w[--verbose README.md CHANGELOG.md])
  end
end
