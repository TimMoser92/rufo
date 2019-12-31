require "find"
require "rake/file_list"

class Rufo::FileFinder
  include Enumerable

  # Taken from https://github.com/ruby/rake/blob/f0a897e3fb557f64f5da59785b1a4464826f77b2/lib/rake/application.rb#L41
  RAKEFILES = [
    "**/rakefile",
    "**/Rakefile",
    "**/rakefile.rb",
    "**/Rakefile.rb",
  ]

  FILENAMES = [
    "**/Gemfile",
    *RAKEFILES,
  ]

  EXTENSIONS = [
    "**/*.rb",
    "**/*.gemspec",
    "**/*.rake",
    "**/*.ru",
    "**/*.jbuilder",
    "**/*.erb",
  ]

  DEFAULT_PATTERNS = [
    *FILENAMES,
    *EXTENSIONS,
  ]

  EXCLUDED_DIRS = [
    "vendor",
  ]

  EXCLUDE_PATTERNS = [
    "vendor/**/*",
  ]

  def initialize(files_or_dirs, includes: [], excludes: [])
    @files_or_dirs = files_or_dirs
    @includes = includes
    @excludes = excludes
  end

  def each
    files_or_dirs.each do |file_or_dir|
      if Dir.exist?(file_or_dir)
        all_rb_files(file_or_dir).each { |file| yield [true, file] }
      else
        yield [File.exist?(file_or_dir), file_or_dir]
      end
    end
  end

  private

  attr_reader :files_or_dirs, :includes, :excludes

  def all_rb_files(file_or_dir)
    Dir.chdir(file_or_dir) do
      fl = Rake::FileList.new(*DEFAULT_PATTERNS)
      fl.exclude(*EXCLUDE_PATTERNS)
      fl.exclude(*excludes)
      fl.include(*includes)
      fl.to_a
    end
  end
end
