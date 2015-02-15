module AudioBookCreator
  class SurferDef
    attr_accessor :host
    attr_accessor :max
    # only set for testing purposes (stubbed to :memory:)
    attr_accessor :regen_html
    attr_accessor :cache_filename

    def initialize(host, max, regen_html, cache_filename)
      @host = host
      @max = max
      @regen_html = regen_html
      @cache_filename = cache_filename
    end
  end
end
