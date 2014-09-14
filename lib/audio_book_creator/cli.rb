require 'optparse'
require 'fileutils'
require 'logger'
require 'uri'

module AudioBookCreator
  class Cli
    include Logging
    def initialize(options = {})
      @options = options
      set_defaults
    end

    attr_reader :base_dir

    # stub for testing
    attr_writer :web

    def set_defaults
      default(:max, 10)
      default(:title_path, "h1")
      default(:body_path, "p")
      default(:link_path, "a")
    end

    def set_args(argv, usage)
      self[:title] = argv.shift
      self[:urls] = argv
      if self[:urls].empty?
        puts "please provide title and url", usage
        exit 2
      end
      default(:database, "#{base_dir}/pages.db")
    end

    # set in parse (in set_args when setting database name)
    # setting max_paragraphs later will not change the filename
    def base_dir
      self[:base_dir] ||= AudioBookCreator.sanitize_filename(self[:title], self[:max_paragraphs])
    end

    def [](name)
      @options[name]
    end

    def []=(name, value)
      @options[name] = value
    end

    def parse(argv)
      options = OptionParser.new do |opts|
        opts.program_name = "audio_book_creator"
        opts.version = VERSION
        opts.banner = "Usage: audio_book_creator [options] title url [url] [...]"
        option(opts, :verbose, "-v", "--verbose", "Run verbosely")
        option(opts, :title_path, "--title STRING", "Title css (e.g.: h1)")
        option(opts, :body_path, "--body STRING", "Content css (e.g.: p)")
        option(opts, :link_path, "--link STRING", "Follow css (e.g.: a.Next)")
        option(opts, :max, "--no-max", "Don't limit the number of pages to visit")
        option(opts, :max, "--max NUMBER", Integer, "Maximum number of pages to visit (default: 10)")
        option(opts, :max_paragraphs, "--max-p NUMBER", Integer, "Max paragraphs per chapter (testing only)")
        option(opts, :regen_audio, "--force-audio", "Regerate the audio")
        option(opts, :regen_html, "--force-html", "Regerate the audio")
        option(opts, :rate, "--rate NUMBER", Integer, "Set words per minute")
        option(opts, :voice, "--voice STRING", "Set speaker voice")
        option(opts, :base_dir, "--base-dir STRING", "Directory to hold files")
      end
      options.parse!(argv)
      set_args(argv, options.to_s)
      self
    end

    def page_def
      @page_def ||= PageDef.new(self[:urls].first, self[:title_path],
                                self[:body_path], self[:link_path], self[:max_paragraphs])
    end

    def book_def
      @book_def ||= BookDef.new(self[:base_dir], self[:title], self[:author])
    end

    # components

    def set_logger
      logger.level = self[:verbose] ? Logger::INFO : Logger::WARN
    end

    def page_cache
      @page_cache ||= PageDb.new(self[:database], force: self[:regen_html])
    end

    def web
      @web ||= Web.new
    end

    def cached_web
      @cached_hash ||= CachedHash.new(page_cache, web)
    end

    def invalid_urls
      @invalid_urls ||= UrlFilter.new(host: self[:urls].first)
    end

    def visited
      @visited ||= ArrayWithCap.new(self[:max])
    end

    def outstanding
      @outstanding ||= CascadingArray.new([], outstanding_chapters)
    end

    def outstanding_chapters
      self[:urls].uniq.map { |url| URI.parse(url) }
    end

    def spider
      @spider ||= Spider.new(cached_web, outstanding, visited, invalid_urls, page_def)
    end

    def editor
      @editor ||= Editor.new(page_def)
    end

    def speaker
      @speaker ||= Speaker.new(book_def, {force: self[:regen_audio]}
                                 .merge(option_hash(:voice, :rate)))
    end

    def binder
      @binder ||= Binder.new(book_def, force: self[:regen_audio])
    end

    def visited_pages
      visited.map { |visited_url| page_cache[visited_url.to_s] }
    end

    def run
      set_logger
      make_directory_structure
      spider.run
      chapters = editor.parse(visited_pages)
      chapters.each do |chapter|
        speaker.say(chapter)
      end
      binder.create(chapters)
    end

    # create the directory that will house the cache and temporary files
    def make_directory_structure
      FileUtils.mkdir(base_dir) unless File.exist?(base_dir)
    end

    private

    def option(opts, value, *args)
      opts.on(*args) { |v| self[value] = v }
    end

    def default(key, value)
      self[key] = value if self[key].nil?
    end

    def option_hash(*keys)
      keys.each_with_object({}) { |key, h| h[key] = self[key] }
    end
  end
end
