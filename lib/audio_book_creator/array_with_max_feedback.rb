module AudioBookCreator
  class ArrayWithMaxFeedback
    include Enumerable
    include Logging
    # @!attribute max
    #   @return Integer the maximum number of pages to visit
    attr_accessor :max

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
      @contents ||= [] # Set
    end

    def include?(url)
      @contents.include?(url)
    end
    alias_method :[], :include?

    def <<(url)
      if url && !include?(url)
        ensure_under_limit
        logger.info { "visit #{url} [#{visited_counter}]" }
        @contents << url
      end
      self
    end

    def each(&block)
      @contents.each(&block)
    end

    private

    def visited_counter
      max ? "#{size + 1}/#{max}" : "#{size + 1}"
    end

    def ensure_under_limit
      raise "visited #{max} pages.\n  use --max to increase pages visited" if over_limit?
    end

    def size
      @contents.size
    end

    def over_limit?
      max && size >= max
    end
  end
end
