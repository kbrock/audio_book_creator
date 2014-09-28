module AudioBookCreator
  class BookDef
    attr_accessor :base_dir
    attr_accessor :title
    attr_accessor :author

    attr_accessor :max_paragraphs

    # only set for testing purposes (stubbed to :memory:)
    attr_accessor :cache_filename

    def initialize(title, author = nil, base_dir = nil, max_paragraphs = nil, cache_filename = nil)
      @title    = title
      @base_dir = base_dir || AudioBookCreator.sanitize_filename(title, max_paragraphs)
      @author   = author   || "Vicki"
      @max_paragraphs = max_paragraphs

      @cache_filename = cache_filename || "#{@base_dir}/pages.db"
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
