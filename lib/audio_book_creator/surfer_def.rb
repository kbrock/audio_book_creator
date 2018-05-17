module AudioBookCreator
  class SurferDef
    attr_accessor :max
    attr_accessor :regen_html
    attr_accessor :existing

    def initialize(max = nil, regen_html = nil, existing = false)
      @max = max
      @regen_html = regen_html
      @existing = existing
    end
  end
end
