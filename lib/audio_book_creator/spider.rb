require 'nokogiri'
require 'uri'

module AudioBookCreator
  class Spider
    include Logging

    # @!attribute web
    #   @return Hash access to the world wide web
    attr_accessor :web
    attr_accessor :invalid_urls

    attr_accessor :page_def

    def initialize(page_def, web = {}, invalid_urls = {})
      @page_def     = page_def
      @web          = web
      @invalid_urls = invalid_urls
    end

    def run(outstanding)
      visited = []
      # hack to support pre-set outstanding

      while (url = uri(outstanding.shift))
        visited << url
        new_pages = visit_page(url)
        new_pages.select do |href|
          !invalid_urls.include?(href) && !visited.include?(href)
        end.each do |href|
          outstanding << href unless outstanding.include?(href)
        end
      end
      visited.map { |u| web[u.to_s] }
    end

    private

    # this one hangs on mutations
    def visit_page(url)
      logger.info { "visit #{url}" }
      doc = Nokogiri::HTML(web[url.to_s])
      page_def.page_links(doc) { |a| uri(url, a["href"]) }
    end

    # raises URI::Error (BadURIError)
    def uri(url, alt = nil)
      return unless url
      url = URI.parse(url) unless url.is_a?(URI)
      url = url + alt if alt
      url.fragment = nil # remove #x part of url
      url
    end
  end
end
