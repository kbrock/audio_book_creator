module AudioBookCreator
  class Binder
    attr_accessor :book_def
    attr_accessor :force

    # these are more for documentation than actual variables

    attr_accessor :channels
    # split on this hour mark
    attr_accessor :max_hours
    attr_accessor :bit_rate
    attr_accessor :sample_rate

    def initialize(book_def, options = {})
      @book_def = book_def
      options.each { |n, v| public_send("#{n}=", v) }
      @channels  ||= 1
      @bit_rate  ||= 32
      @max_hours ||= 7
      @sample_rate ||= 22_050
    end

    def create(chapters)
      raise "No Chapters" if chapters.nil? || chapters.empty?

      if AudioBookCreator.should_write?(book_def.filename, force)
        Runner.new.run!("abbinder", params: params(chapters))
      end
    end

    private

    def params(chapters)
      {
        "-a" => book_def.author,
        "-t" => book_def.title,
        "-b" => bit_rate,
        "-c" => channels,
        "-r" => sample_rate,
        "-g" => "Audiobook",
        "-l" => max_hours,
        "-o" => book_def.filename,
        # "-v" => verbose,
        # "-A" => nil, #    add audiobook to iTunes
        # "-C" => "file.png" cover image
        nil  => chapter_params(chapters),
      }
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
