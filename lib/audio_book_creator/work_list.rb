module AudioBookCreator
  class WorkList

    # @!attribute outstanding
    #   @return Array<URI> the pages not visited yet
    attr_accessor :outstanding

    def initialize
      # want a set, but want to make sure fifo
      @outstanding = []
    end

    def include?(url)
      outstanding.include?(url)
    end
    alias_method :[], :include?

    def <<(url)
      outstanding << url if url && !include?(url)
      self
    end

    def shift
      outstanding.shift
    end
  end
end
