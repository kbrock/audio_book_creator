module AudioBookCreator
  class ArrayWithCap < Array
    include Enumerable
    # @!attribute max
    #   @return Integer the maximum number of pages to visit
    attr_accessor :max

    def initialize(max = nil)
      super(0)
      @max = max
    end

    def <<(url)
      ensure_under_limit
      super
    end

    private

    def ensure_under_limit
      raise "visited #{max} pages" if over_limit?
    end

    def over_limit?
      max && size >= max
    end
  end
end
