module AudioBookCreator
  class SurferDef
    attr_accessor :host
    attr_accessor :max
    attr_accessor :regen_html

    def initialize(host = nil, max = nil, regen_html = nil)
      @host = host
      @max = max
      @regen_html = regen_html
    end
  end
end
