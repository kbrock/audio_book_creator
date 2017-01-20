module AudioBookCreator
  class BookDef
    attr_accessor :base_dir
    attr_accessor :title
    attr_accessor :author

    attr_accessor :urls
    attr_accessor :itunes

    def initialize(title = nil, author = nil, base_dir = nil, urls = nil, itunes = nil)
      @title    = title
      @base_dir = base_dir
      @author   = author   || "Vicki"
      @urls = urls
      @itunes = itunes
    end

    def filename
      BookDef.sanitize_filename(title, "m4b")
    end

    def base_dir
      @base_dir || BookDef.sanitize_filename(title)
    end

    def unique_urls
      urls.uniq
    end

    private

    def self.sanitize_filename(*filenames)
      filenames.join(".").gsub(/[^-._a-z0-9A-Z]/, "-").gsub(/-+/, "-").sub(/-\z/, "")
    end
  end
end
