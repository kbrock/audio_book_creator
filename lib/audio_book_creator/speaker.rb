module AudioBookCreator
  class Speaker
    attr_accessor :book_def
    attr_accessor :force

    def initialize(book_def, options = {})
      @book_def = book_def
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def say(chapter)
      raise "Empty chapter" if chapter.empty?
      text_filename = book_def.chapter_text_filename(chapter)
      sound_filename = book_def.chapter_sound_filename(chapter)

      File.write(text_filename, chapter.to_s) if AudioBookCreator.should_write?(text_filename, force)
      if AudioBookCreator.should_write?(sound_filename, force)
        Runner.new.run!("say", params: params(text_filename, sound_filename))
      end
    end

    private

    def params(text_filename, sound_filename)
      {
        "-v" => book_def.voice,
        "-r" => book_def.rate,
        "-f" => text_filename,
        "-o" => sound_filename,
      }
    end
  end
end
