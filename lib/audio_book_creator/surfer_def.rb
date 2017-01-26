module AudioBookCreator
  class SurferDef
    attr_accessor :max
    attr_accessor :regen_html

    def initialize(max = nil, regen_html = nil)
      @max = max
      @regen_html = regen_html
    end
  end
end
