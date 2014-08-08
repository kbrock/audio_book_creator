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

    def set_args(argv, usage)
      self[:title] = argv.shift
      self[:urls] = argv
      if self[:urls].empty?
        puts "please provide title and url", usage
        exit 1
      else
        self[:database] = "#{base_dir}/pages.db"
        # TODO: use self[:urls].first to guess :follow
        self[:follow] ||= "a"
      end
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

      options = OptionParser.new do |opts|
        opts.program_name = File.basename($PROGRAM_NAME)
        opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options] title url [url]"
        opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| self[:verbose] = v }
        opts.on("-a", "--follow STRING", "Follow css (e.g.: a.Next)") { |v| self[:follow] = v }
        opts.on(      "--no-max", "Don't limit the number of pages to visit") { self[:max] = nil }
        opts.on(      "--max NUMBER", Integer, "Maximum number of pages to visit (default: #{self[:max]})") do |v|
          self[:max] = v
        end
        opts.on("--multi-site", "Allow spider to visit multiple sites") { self[:multi_site] = true }
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts.to_s
          exit 0
        end

        opts.on_tail("--version", "Show version") do
          puts "audio_book_creator #{::AudioBookCreator::VERSION}"
          exit 0
        end
      end
      options.parse!(argv)
      set_args(argv, options.to_s)
      self
    end

    # components

    def page_cache
      @page_cache ||= PageDb.new(self[:database])
    end

    def spider
      @spider ||= Spider.new(page_cache, option_hash(:verbose, :load_from_cache, :max, :multi_site))
    end

    def editor
      @editor ||= Editor.new
    end

    def speaker
      @speaker ||= Speaker.new
    end

    def run
      make_directory_structure
      pages = spider.visit(self[:urls]).run(self[:follow])
      chapters = editor.parse(base_dir, pages)
      chapters.each do |chapter|
        speaker.say(chapter)
      end
    end

    def make_directory_structure
      FileUtils.mkdir(base_dir) unless File.exist?(base_dir)
    end

    def default(key, value)
      self[key] = value if self[key].nil?
    end

    def option_hash(*keys)
      if keys.first.is_a?(Hash)
        keys.first.each_with_object({}) { |(key, value), h| h[key] = self[value] }
      else
        keys.flatten.each_with_object({}) { |key, h| h[key] = self[key] }
      end
    end
  end
end
