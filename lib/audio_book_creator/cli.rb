require 'optparse'
require 'fileutils'
require 'logger'
require 'uri'

module AudioBookCreator
  class Cli
    include Logging
    def initialize
      self.verbose = false
      surfer_def.max = 10
      page_def.title_path = "h1"
      page_def.body_path = "p"
      page_def.link_path = "a"
    end

    # stub for testing
    attr_writer :web

    def set_args(argv, usage)
      if argv.empty?
        puts "please url", usage
        exit 2
      elsif argv.first.include?("://")
        book_def.title = argv.first.split("/").last
        book_def.urls = argv
      else
        book_def.title = argv.shift
        book_def.urls = argv
      end
      surfer_def.cache_filename = database
      surfer_def.host = book_def.urls.first
    end

    def database
      "pages.db"
    end

    def verbose=(val)
      logger.level = val ? Logger::INFO : Logger::WARN
    end

    def parse(argv)
      options = OptionParser.new do |opts|
        opts.program_name = "audio_book_creator"
        opts.version = VERSION
        opts.banner = "Usage: audio_book_creator [options] title url [url] [...]"
        option(opts, :self, :verbose, "-v", "--verbose", "Run verbosely") { |v| self.verbose = v }
        # 
        option(opts, :page_def, :title_path, "--title STRING", "Title css (e.g.: h1)")
        option(opts, :page_def, :body_path, "--body STRING", "Content css (e.g.: p)")
        option(opts, :page_def, :link_path, "--link STRING", "Next Page css (e.g.: a.Next)")
        option(opts, :page_def, :chapter_path, "--chapter STRING", "Next Chapter css")
        option(opts, :surfer_def, :max, "--no-max", "Don't limit the number of pages to visit")
        option(opts, :surfer_def, :max, "--max NUMBER", Integer, "Maximum number of pages to visit (default: 10)")
        option(opts, :page_def, :max_paragraphs, "--max-p NUMBER", Integer, "Max paragraphs per chapter (testing only)")
        option(opts, :speaker_def, :regen_audio, "--force-audio", "Regerate the audio")
        option(opts, :surfer_def, :regen_html, "--force-html", "Regerate the audio")
        option(opts, :speaker_def, :rate, "--rate NUMBER", Integer, "Set words per minute")
        option(opts, :speaker_def, :voice, "--voice STRING", "Set speaker voice")
        option(opts, :book_def, :base_dir, "--base-dir STRING", "Directory to hold files")
        option(opts, :book_def, :itunes, "--itunes", "-A", "Load book into itunes")
      end
      options.parse!(argv)
      set_args(argv, options.to_s)
      self
    end

    # parameter objects

    def page_def
      @page_def ||= PageDef.new
    end

    def book_def
      @book_def ||= BookDef.new
    end

    def speaker_def
      @speaker_def ||= SpeakerDef.new
    end

    def surfer_def
      @surfer_def ||= SurferDef.new
    end

    def conductor
      @conductor ||= Conductor.new(page_def, book_def, speaker_def, surfer_def)
    end

    def run
      conductor.run
    end

    private

    def option(opts, model, value, *args, &block)
      if block_given?
        opts.on(*args, &block)
      else
        opts.on(*args) { |v| self.send(model).send("#{value}=", v) }
      end
    end
  end
end
