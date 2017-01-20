module AudioBookCreator
  class CachedHash
    # @!attribute caching layer
    #   @return Hash<String, String> cache
    attr_accessor :cache

    # @!attribute main hash
    #   @return Hash<String, String> hash for main content
    attr_accessor :main

    def initialize(cache, main)
      @cache = cache
      @main  = main
    end

    def [](name)
      @cache[name] ||= main[name]
    end
  end
end
