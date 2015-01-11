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
      @base_dir = base_dir || BookDef.sanitize_filename(title, max_paragraphs)
      @author   = author   || "Vicki"
      @max_paragraphs = max_paragraphs

      @cache_filename = cache_filename || "#{@base_dir}/pages.db"
    end

    def filename
      BookDef.sanitize_filename(title, "m4b")
    end

    private

    def self.sanitize_filename(*filenames)
      filenames.compact.join(".").gsub(/[^-._a-z0-9A-Z]/, "-").gsub(/--*/, "-").sub(/-$/, "")
    end
  end
end
