require 'bundler/setup'

require 'jekyll'

Rake.add_rakelib '_lib/tasks'

class String
  def bold
    "\033[1m#{self}\033[0m"
  end
end


task :default => :build