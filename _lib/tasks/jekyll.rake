# Rake Jekyll tasks
desc 'Build the static jekyll site'
task :build do
  puts 'Building site...'.bold
  Jekyll::Commands::Build.process(profile: true)
end

desc 'Clean all build products'
task :clean do
  puts 'Cleaning up _site...'.bold
  Jekyll::Commands::Clean.process({})
end
