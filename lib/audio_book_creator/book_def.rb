module AudioBookCreator
  class BookDef
    attr_accessor :base_dir
    attr_accessor :title
    attr_accessor :author

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
    attr_accessor :max_paragraphs

    # only set for testing purposes (stubbed to :memory:)
    attr_accessor :cache_filename

    def initialize(title, author = nil, base_dir = nil, voice = nil, rate = nil, max_paragraphs = nil)
      @title    = title
      @base_dir = base_dir || AudioBookCreator.sanitize_filename(title, max_paragraphs)
      @author   = author   || "Vicki"
      # speaker prefs
      @voice    = voice    || "Vicki"
      @rate     = rate     || 280
      @max_paragraphs = max_paragraphs

      @cache_filename = "#{@base_dir}/pages.db"
    end

    def chapter_text_filename(chapter)
      "#{base_dir}/#{chapter.filename}.txt"
    end

    def chapter_sound_filename(chapter)
      "#{base_dir}/#{chapter.filename}.m4a"
    end

    def filename
      AudioBookCreator.sanitize_filename(title, "m4b")
    end
  end
end
