module AudioBookCreator
  class Conductor
    attr_accessor :page_def
    attr_accessor :book_def
    attr_accessor :speaker_def
    attr_accessor :surfer_def

    # specs only
    attr_writer :page_cache

    def initialize(page_def, book_def, speaker_def, surfer_def)
      @page_def    = page_def
      @book_def    = book_def
      @speaker_def = speaker_def
      @surfer_def  = surfer_def

      page_def.invalid_urls = invalid_urls
    end

    # components

    ## spider

    def page_cache
      @page_cache ||= PageDb.new("pages.db", "pages", false)
    end

    def web
      @web ||= Web.new(surfer_def.max)
    end

    def cached_web
      @cached_hash ||= CachedHash.new(page_cache, web)
    end

    def invalid_urls
      @invalid_urls ||= UrlFilter.new(book_def.urls.first)
    end

    def spider
      @spider ||= Spider.new(page_def, cached_web)
    end

    ##

    def editor
      @editor ||= Editor.new(page_def)
    end

    def speaker
      @speaker ||= speaker_def.mute ? SpeakerMute.new(speaker_def, book_def) : Speaker.new(speaker_def, book_def)
    end

    def binder
      @binder ||= Binder.new(book_def, speaker_def)
    end

    ##

    def creator
      @creator ||= BookCreator.new(spider, editor, speaker, binder)
    end

    def outstanding
      @outstanding ||= book_def.unique_urls
    end

    def include?(url)
      page_cache.include?(url)
    end

    def run
      creator.create(outstanding)
    end
  end
end
