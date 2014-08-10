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
        exit 1
      end
    end

    def base_dir
      @base_dir ||= [self[:title], self[:max_paragraphs]].compact.join("-")
       .gsub(/\W/,"-").gsub(/--*/,"-").gsub(/-$/,"").downcase
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
        opts.on(      "--title STRING", "Content css (e.g.: h1)") { |v| self[:title_path] = v }
        opts.on(      "--body STRING", "Content css (e.g.: p)") { |v| self[:body_path] = v }
        opts.on(      "--link STRING", "Follow css (e.g.: a.Next)") { |v| self[:link_path] = v }
        opts.on(      "--no-max", "Don't limit the number of pages to visit") { self[:max] = nil }
        opts.on(      "--max NUMBER", Integer, "Maximum number of pages to visit (default: #{self[:max]})") do |v|
          self[:max] = v
        end
        opts.on("--max-p NUMBER", Integer, "Max paragraphs per chapter (testing only)") do |v|
          self[:max_paragraphs] = v
        end
        opts.on("--force-audio", "Regerate the audio") { |v| self[:regen_audio] = v }
        opts.on("--force-html", "Regerate the audio") { |v| self[:regen_html] = v }
        opts.on("--multi-site", "Allow spider to visit multiple sites") { |v| self[:multi_site] = v }
        opts.on("--rate NUMBER", Integer, "Set words per minute") { |v| self[:rate] = v }
        opts.on("--voice STRING", "Set speaker voice") { |v| self[:voice] = v }
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
      @page_cache ||= PageDb.new("#{base_dir}/pages.db", force: self[:regen_html])
    end

    def spider
      @spider ||= Spider.new(page_cache, option_hash(:verbose, :max, :multi_site))
    end

    def editor
      @editor ||= Editor.new(option_hash(:title_path, :body_path, :max_paragraphs))
    end

    def speaker
      @speaker ||= Speaker.new({base_dir: base_dir, force: self[:regen_audio]}
                                 .merge(option_hash(:verbose, :voice, :rate)))
    end

    def binder
      @binder ||= Binder.new({base_dir: base_dir, force: self[:regen_audio]}
                               .merge(option_hash(:verbose, :title)))
    end

    def run
      make_directory_structure
      page_cache.create
      pages = spider.visit(self[:urls]).run(self[:link_path])
      chapters = editor.parse(pages)
      chapters.each do |chapter|
        speaker.say(chapter)
      end
      binder.create(chapters)
    end

    def make_directory_structure
      FileUtils.mkdir(base_dir) unless File.exist?(base_dir)
    end

    private

    def default(key, value)
      self[key] = value if self[key].nil?
    end

    def option_hash(*keys)
      keys.flatten.each_with_object({}) { |key, h| h[key] = self[key] }
    end
  end
end
