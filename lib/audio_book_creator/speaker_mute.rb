module AudioBookCreator
  class SpeakerMute < Speaker
    # def initialize(speaker_def, book_def)
    #   @speaker_def = speaker_def
    #   @book_def = book_def
    # end

    def say(chapter)
      raise "Empty Chapter" if chapter.empty?
      text_filename = chapter_text_filename(chapter)
      sound_filename = chapter_sound_filename(chapter)

      AudioBookCreator.optionally_write(text_filename, force) { chapter.to_s }

      nil
    end
  end
end
