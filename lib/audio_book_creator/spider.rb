require 'nokogiri'
require 'uri'

module AudioBookCreator
  class Spider
    include Logging

    # @!attribute web
    #   @return Hash access to the world wide web
    attr_accessor :web
    attr_accessor :outstanding
    attr_accessor :visited
    attr_accessor :invalid_urls

    attr_accessor :page_def

    def initialize(web = {}, outstanding = [], visited = [], invalid_urls = {}, page_def)
      @web             = web
      @outstanding     = outstanding
      @visited         = visited
      @invalid_urls    = invalid_urls
      @page_def        = page_def
    end

    # Add a url to the outstanding list of pages to visit
    def <<(url)
      if (url = uri(url)) && valid_link?(url)
        outstanding << url
      end
      self
    end
    alias_method :visit, :<<

    def valid_link?(url)
      !outstanding.include?(url) && !invalid_urls.include?(url) && !visited.include?(url)
    end

    def run
      while (url = outstanding.shift)
        visit_page(url)
      end
    end

    private

    # this one hangs on mutations
    def visit_page(url)
      visited << url
      logger.info { "visit #{url}" }
      follow_url(url)
    end

    def follow_url(url)
      follow_links url, Nokogiri::HTML(web[url.to_s])
    end

    # raises URI::Error (BadURIError)
    def uri(url, alt = nil)
      url = URI.parse(url) unless url.is_a?(URI)
      url = url + alt if alt
      url.fragment = nil # remove #x part of url
      url
    end

    # possibly move valid_link? from <<() to follow_links()
    def follow_links(url, doc)
      page_def.links(doc) do |a|
        self << uri(url, a["href"])
      end
    end
  end
end
