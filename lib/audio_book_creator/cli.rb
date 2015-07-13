require 'optparse'
require 'fileutils'
require 'logger'
require 'uri'

module AudioBookCreator
  class Cli
    include Logging

    # stub for testing
    attr_writer :web

    def verbose=(val)
      logger.level = val ? Logger::INFO : Logger::WARN
    end

    def parse(argv)
      options = OptionParser.new do |opts|
        opts.program_name = "audio_book_creator"
        opts.version = VERSION
        opts.banner = "Usage: audio_book_creator [options] title url [url] [...]"
        opt(opts, self) do |o|
          o.opt(:verbose, "-v", "--verbose", "--[no-]verbose", "Run verbosely")
        end
        opt(opts, page_def) do |o|
          o.opt(:title_path, "--title STRING", "Title css (e.g.: h1)")
          o.opt(:body_path, "--body STRING", "Content css (e.g.: p)")
          o.opt(:link_path, "--link STRING", "Next Page css (e.g.: a.Next)")
          o.opt(:chapter_path, "--chapter STRING", "Next Chapter css")
        end
        opt(opts, surfer_def) do |o|
          o.opt(:max, "--no-max", "Don't limit the number of pages to visit")
          o.opt(:max, "--max NUMBER", Integer, "Maximum number of pages to visit")
          o.opt(:regen_html, "--force-html", "Regerate the audio")
        end
        opt(opts, speaker_def) do |o|
          o.opt(:regen_audio, "--force-audio", "Regerate the audio")
          o.opt(:rate, "--rate NUMBER", Integer, "Set words per minute")
          o.opt(:voice, "--voice STRING", "Set speaker voice")
        end
        opt(opts, book_def) do |o|
          o.opt(:base_dir, "--base-dir STRING", "Directory to hold files")
          o.opt(:itunes, "--itunes", "-A", "Load book into itunes")
        end
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

    def opt(opts, model)
      yield OptSetter.new(opts, model)
    end

    class OptSetter
      def initialize(opts, model)
        @opts  = opts
        @model = model
      end

      def opt(value, *args)
        @opts.on(*args) { |v| @model.send("#{value}=", v) }
      end
    end

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
      surfer_def.host = book_def.urls.first
    end
  end
end
