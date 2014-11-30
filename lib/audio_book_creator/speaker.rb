module AudioBookCreator
  class Speaker
    attr_accessor :speaker_def
    attr_accessor :book_def
    attr_accessor :force

    def initialize(speaker_def, book_def, options = {})
      @speaker_def = speaker_def
      @book_def = book_def
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def say(chapter)
      raise "Empty chapter" if chapter.empty?
      text_filename = book_def.chapter_text_filename(chapter)
      sound_filename = book_def.chapter_sound_filename(chapter)

      if AudioBookCreator.should_write?(text_filename, force)
        File.write(text_filename, chapter.to_s)
      end

      if AudioBookCreator.should_write?(sound_filename, force)
        Runner.new.run!("say", params: params(text_filename, sound_filename))
      end
    end

    private

    def params(text_filename, sound_filename)
      {
        "-v" => speaker_def.voice,
        "-r" => speaker_def.rate,
        "-f" => text_filename,
        "-o" => sound_filename,
      }
    end
  end
end
