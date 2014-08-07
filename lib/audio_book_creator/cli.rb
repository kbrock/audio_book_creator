require 'optparse'
require 'fileutils'

module AudioBookCreator
  class Cli
    attr_accessor :argv

    def initialize(options = {})
      @options = options
      set_defaults
    end

    def set_defaults
      default(:database, ":memory:")
      default(:verbose, false)
      default(:max, 10)
      default(:load_from_cache, true)
    end

    def base_dir
      @base_dir ||= self[:title].gsub(" ", "-")
    end

    def [](name)
      @options[name]
    end

    def []=(name, value)
      @options[name] = value
    end

    def parse(argv = [], _env = {})
      self.argv = argv.dup

      OptionParser.new do |opts|
        opts.program_name = File.basename($PROGRAM_NAME)
        opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options] title url"
        opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| self[:verbose] = v }
        opts.on(      "--no-max", "Don't limit the number of pages to visit") { self[:max] = nil }
        opts.on(      "--max NUMBER", Integer, "Maximum number of pages to visit (default: #{self[:max]})") do |v|
          self[:max] = v
        end
      end.parse!(argv)

      self[:title] = argv.shift
      self[:urls] = argv
      self[:database] = "#{base_dir}/pages.db"

      self
    end

    # components

    def page_cache
      @page_cache ||= PageDb.new(self[:database])
    end

    def spider
      @spider ||= Spider.new(page_cache, verbose: self[:verbose], load_from_cache: self[:load_from_cache])
    end

    def run
      make_directory_structure
      pages = spider.visit(self[:urls]).run
    end

    def make_directory_structure
      FileUtils.mkdir(base_dir) unless File.exist?(base_dir)
    end

    def default(key, value)
      self[key] = value if self[key].nil?
    end
  end
end
