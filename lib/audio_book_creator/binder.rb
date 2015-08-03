module AudioBookCreator
  class Binder
    attr_accessor :book_def
    attr_accessor :speaker_def

    # these are more for documentation than actual variables

    def initialize(book_def, speaker_def)
      @book_def = book_def
      @speaker_def = speaker_def
    end

    def create(chapters)
      raise "No Chapters" if chapters.nil? || chapters.empty?

      AudioBookCreator.optionally_run(book_def.filename, force) do
        ["abbinder", params: params(chapters)]
      end
    end

    private

    def force
      speaker_def.regen_audio
    end

    def itunes
      book_def.itunes
    end

    def params(chapters)
      ret = {
        "-A" => nil,
        "-a" => book_def.author,
        "-t" => book_def.title,
        "-b" => speaker_def.bit_rate,
        "-c" => speaker_def.channels,
        "-r" => speaker_def.sample_rate,
        "-g" => "Audiobook",
        "-l" => speaker_def.max_hours,
        "-o" => book_def.filename,
        # "-v" => verbose,
        # "-C" => "file.png" cover image
        nil  => chapter_params(chapters),
      }
      ret.delete("-A") unless itunes # add audiobook to iTunes
      ret
    end

    def chapter_params(chapters)
      chapters.map { |ch| [ctitle(ch), cfilename(ch)] }
    end

    def ctitle(chapter)
      "@#{chapter.title}@"
    end

    def cfilename(chapter)
      chapter.filename
    end
  end
end
