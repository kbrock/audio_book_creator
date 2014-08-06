require 'optparse'
require 'fileutils'

module AudioBookCreator
  class Cli

    attr_accessor :options
    attr_accessor :argv

    def initialize(options = {})
      self.options = options
      set_defaults
    end

    def set_defaults
      options[:database] ||= ":memory:"
      options[:verbose]  ||= false
      options[:max]      ||= 10
    end

    def base_dir
      @base_dir ||= options[:title].gsub(" ","-")
    end

    def [](name)
      options[name]
    end

    def []=(name, value)
      options[name] = value
    end

    def parse(argv = [], env = {})
      self.argv = argv.dup

      OptionParser.new do |opts|
        opts.program_name = File.basename($0)
        opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options] title url"
        opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| options[:verbose] = v }
        opts.on(      "--no-max", "Don't limit the number of pages to visit") { |v| options[:max] = nil }
        opts.on(      "--max NUMBER", Integer, "Maximum number of pages to visit (default: #{options[:max]})") do |v|
          options[:max] = v
        end
      end.parse!(argv)

      options[:title] = argv.shift
      options[:urls] = argv
      options[:database] = "#{base_dir}/pages.db"

      self
    end

    def run
      make_directory_structure
      pages = PageDb.new(options[:database])
      spider = Spider.new(pages, { verbose: options[:verbose]})
      spider.visit(options[:urls])

      spider.run
    end

    def make_directory_structure
      FileUtils.mkdir(base_dir) unless File.exist?(base_dir)
    end
  end
end
