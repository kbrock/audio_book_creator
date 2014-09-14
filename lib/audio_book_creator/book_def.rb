module AudioBookCreator
  class BookDef
    attr_accessor :base_dir
    attr_accessor :title
    attr_accessor :author

    #attr_accessor :force

    def initialize(base_dir, title = nil, author = nil)
      @base_dir = base_dir
      @title = title
      @author = author || "Vicki"
    end

    def title
      @title || base_dir
    end

    def chapter_text_filename(chapter)
      "#{base_dir}/#{chapter.filename}.txt"
    end

    def chapter_sound_filename(chapter)
      "#{base_dir}/#{chapter.filename}.m4a"
    end

    def cache_filename
      "#{base_dir}/pages.db"
    end

    def filename
      AudioBookCreator.sanitize_filename(title, "m4b")
    end
  end
end
