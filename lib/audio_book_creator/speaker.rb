module AudioBookCreator
  class Speaker
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

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
      @voice   ||= "Vicki"
      @rate    ||= 320
    end

    def say(chapter)
      raise "Empty chapter" if chapter.empty?
      File.write(text_filename(chapter), chapter.to_s) if AudioBookCreator.should_write?(text_filename(chapter), force)
      if AudioBookCreator.should_write?(sound_filename(chapter), force)
        Runner.new.run!("say", params: params(chapter))
      end
    end

    private

    def params(chapter)
      {
        "-v" => voice,
        "-r" => rate,
        "-f" => text_filename(chapter),
        "-o" => sound_filename(chapter),
      }
    end

    def sound_filename(chapter)
      "#{base_dir}/#{chapter.filename}.m4a"
    end

    def text_filename(chapter)
      "#{base_dir}/#{chapter.filename}.txt"
    end
  end
end
