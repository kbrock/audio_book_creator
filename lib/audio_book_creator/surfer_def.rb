module AudioBookCreator
  class SurferDef
    attr_accessor :host
    attr_accessor :max
    attr_accessor :regen_html
    attr_accessor :cache_filename

    def initialize(host = nil, max = nil, regen_html = nil, cache_filename = nil)
      @host = host
      @max = max
      @regen_html = regen_html
      @cache_filename = cache_filename
    end
  end
end
