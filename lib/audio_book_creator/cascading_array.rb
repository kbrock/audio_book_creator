module AudioBookCreator
  # this fetching from the first array, fetching from the second if nothing is available
  class CascadingArray

    # @!attribute main
    #   @return Array the alternative array if this one is empty
    attr_accessor :main

    # @!attribute alt
    #   @return Array the alternative array if this one is empty
    attr_accessor :alt

    def initialize(main, alt)
      @main = main
      @alt = alt
    end

    def <<(value)
      @main << value
    end

    def include?(value)
      @main.include?(value) || @alt.include?(value)
    end

    def shift
      @main.shift || @alt.shift
    end
  end
end
