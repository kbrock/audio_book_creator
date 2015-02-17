module AudioBookCreator
  class Speaker
    attr_accessor :speaker_def
    attr_accessor :book_def

    def initialize(speaker_def, book_def)
      @speaker_def = speaker_def
      @book_def = book_def
    end

    def make_directory_structure
      FileUtils.mkdir(base_dir) unless File.exist?(base_dir)
    end

    def say(chapter)
      raise "Empty chapter" if chapter.empty?
      text_filename = chapter_text_filename(chapter)
      sound_filename = chapter_sound_filename(chapter)

      AudioBookCreator.optionally_write(text_filename, force) { chapter.to_s }
      AudioBookCreator.optionally_run(sound_filename, force) do
        ["say", params: params(text_filename, sound_filename)]
      end
      SpokenChapter.new(chapter.title, sound_filename)
    end

    def chapter_text_filename(chapter)
      "#{base_dir}/#{chapter.filename}.txt"
    end

    def chapter_sound_filename(chapter)
      "#{base_dir}/#{chapter.filename}.m4a"
    end

    private

    def base_dir
      book_def.base_dir
    end

    def force
      speaker_def.regen_audio
    end

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
