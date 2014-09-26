require 'open-uri'
require 'uri'

module AudioBookCreator
  class Web
    include Logging

    # @!attribute max
    #   @return Integer the maximum number of pages to visit
    attr_accessor :max

    # @!attribute count
    #   @return Integer the number of pages visited
    attr_accessor :count

    def initialize(max = nil)
      @max = max
      @count = 0
    end

    def [](url)
      @count += 1
      log_page(url)
      check_limit
      open(url.to_s).read
    end

    private

    def log_page(url)
      logger.info do
        max ? "fetch  #{url} [#{count}/#{max}]" : "fetch  #{url} [#{count}]"
      end
    end

    def check_limit
      raise "visited #{max} pages" if over_limit?
    end

    def over_limit?
      max && count > max
    end
  end
end
