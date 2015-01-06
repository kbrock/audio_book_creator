module AudioBookCreator
  class Binder
    attr_accessor :book_def
    attr_accessor :speaker_def
    attr_accessor :force
    attr_accessor :itunes

    # these are more for documentation than actual variables

    def initialize(book_def, speaker_def, options = {})
      @book_def = book_def
      @speaker_def = speaker_def
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def create(chapters)
      raise "No Chapters" if chapters.nil? || chapters.empty?

      if AudioBookCreator.should_write?(book_def.filename, force)
        Runner.new.run!("abbinder", params: params(chapters))
      end
    end

    private

    def params(chapters)
      ret = {
        "-A" => nil, # add audiobook to iTunes
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
      ret.delete("-A") unless itunes
      ret
    end

    def chapter_params(chapters)
      chapters.map { |ch| [ctitle(ch), cfilename(ch)] }
    end

    def ctitle(chapter)
      "@#{chapter.title}@"
    end

    def cfilename(chapter)
      book_def.chapter_sound_filename(chapter)
    end
  end
end
