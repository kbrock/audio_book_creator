module AudioBookCreator
  class Speaker
    attr_accessor :book_def
    #attr_accessor :speaker_def #voice, rate
    attr_accessor :base_dir
    attr_accessor :force

    # currently like the following voices:
    # Vicki             # 10
    # Serena            #  8 UK
    # Allison           #  ? (ok)
    # Moira             #  7 Irish
    # Fiona             #  5 Scottish
    # Kate              #  4 UK
    # Susan             #  2
    # Zosia             # 0 Poland
    # Angelica          # 0 Mexican?
    # Paulina           # 0 Mexican
    attr_accessor :voice
    attr_accessor :rate

    def initialize(book_def, options = {})
      @book_def = book_def
      options.each { |n, v| public_send("#{n}=", v) }
      @voice   ||= "Vicki"
      @rate    ||= 280
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
        "-v" => voice,
        "-r" => rate,
        "-f" => text_filename,
        "-o" => sound_filename,
      }
    end
  end
end
