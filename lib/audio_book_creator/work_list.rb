module AudioBookCreator
  class WorkList
    # @!attribute max
    #   @return Integer the maximum number of pages to visit
    attr_accessor :max

    # @!attribute outstanding
    #   @return Array<URI> the pages not visited yet
    attr_accessor :outstanding

    # @!attribute visited
    #   @return Array<URI> the pages visited
    attr_accessor :visited

    def initialize(options = {})
      @outstanding = []
      @visited = []
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def known?(url)
      outstanding.include?(url) || visited.include?(url)
    end

    def <<(url)
      outstanding << url if !known?(url)
      self
    end

    def shift
      outstanding.shift.tap { |url|
        if url
          ensure_under_limit
          visited << url
        end
      }
    end

    # not sure if limits belongs here

    # this is called right before visiting a page, so we tack on an extra 1
    def visited_counter
      "#{visited.size + 1}/#{max || "all"}"
    end

    def ensure_under_limit
      raise "visited #{max} pages.\n  use --max to increase pages visited" if over_limit?
    end

    def over_limit?
      max && visited.size >= max
    end

    # def size
    #   visited.size
    # end
  end
end
