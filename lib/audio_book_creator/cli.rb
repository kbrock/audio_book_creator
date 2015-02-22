require 'optparse'
require 'fileutils'
require 'logger'
require 'uri'

module AudioBookCreator
  class Cli
    include Logging
    def initialize
      @options = {max: 10, title_path: "h1", body_path: "p", link_path: "a"}
    end

    # stub for testing
    attr_writer :web

    def set_args(argv, usage)
      first = argv.first
      if !first
        puts "please url", usage
        exit 2
      elsif first.include?("://")
        self[:title] = argv.first.split("/").last
        self[:urls] = argv
      else
        self[:title] = argv.shift
        self[:urls] = argv
      end
    end

    def database
      "#{book_def.base_dir}/pages.db"
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
        # 
        option(opts, :title_path, "--title STRING", "Title css (e.g.: h1)")
        option(opts, :body_path, "--body STRING", "Content css (e.g.: p)")
        option(opts, :link_path, "--link STRING", "Next Page css (e.g.: a.Next)")
        option(opts, :chapter_path, "--chapter STRING", "Next Chapter css")
        option(opts, :max, "--no-max", "Don't limit the number of pages to visit")
        option(opts, :max, "--max NUMBER", Integer, "Maximum number of pages to visit (default: 10)")
        option(opts, :max_paragraphs, "--max-p NUMBER", Integer, "Max paragraphs per chapter (testing only)")
        option(opts, :regen_audio, "--force-audio", "Regerate the audio")
        option(opts, :regen_html, "--force-html", "Regerate the audio")
        option(opts, :rate, "--rate NUMBER", Integer, "Set words per minute")
        option(opts, :voice, "--voice STRING", "Set speaker voice")
        option(opts, :base_dir, "--base-dir STRING", "Directory to hold files")
        option(opts, :itunes, "--itunes", "-A", "Load book into itunes")
      end
      options.parse!(argv)
      set_args(argv, options.to_s)
      self
    end

    # parameter objects

    def page_def
      @page_def ||= PageDef.new(self[:title_path], self[:body_path], self[:link_path], self[:chapter_path],
                                self[:max_paragraphs])
    end

    def book_def
      @book_def ||= BookDef.new(self[:title], nil, self[:base_dir], self[:urls],
                                self[:itunes])
    end

    def speaker_def
      @speaker_def ||= SpeakerDef.new(voice: self[:voice], rate: self[:rate], regen_audio: self[:regen_audio])
    end

    def surfer_def
      @surfer_def ||= SurferDef.new(self[:urls].first, self[:max], self[:regen_html], database)
    end

    def verbose
      self[:verbose]
    end

    def conductor
      @conductor ||= Conductor.new(page_def, book_def, speaker_def, surfer_def)
    end

    def set_logger
      logger.level = verbose ? Logger::INFO : Logger::WARN
    end

    def run
      set_logger
      conductor.run
    end

    private

    def option(opts, value, *args)
      opts.on(*args) { |v| self[value] = v }
    end
    # def option(opts, model, value, *args)
    #   opts.on(*args) { |v| self.send(model).send(value) = v }
    # end
  end
end
