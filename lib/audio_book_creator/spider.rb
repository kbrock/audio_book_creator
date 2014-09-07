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

    attr_accessor :link_path

    def initialize(web = {}, outstanding = [], visited = [], invalid_urls = {}, options = {})
      @web             = web
      @outstanding     = outstanding
      @visited         = visited
      @invalid_urls    = invalid_urls
      options.each { |n, v| public_send("#{n}=", v) }
    end

    # Add a url to the outstanding list of pages to visit
    def <<(url)
      if (url = uri(url)) && !outstanding.include?(url) && !invalid_urls.include?(url) && !visited.include?(url)
        outstanding << url
      end
      self
    end
    alias_method :visit, :<<

    def run
      while (url = outstanding.shift)
        visited << url
        logger.info { "visit #{url}" } #" [#{visited_counter}]" }
        follow_links url, Nokogiri::HTML(web[url.to_s])
      end
    end

    private

    # raises URI::Error (BadURIError)
    def uri(url, alt = nil)
      url = URI.parse(url) unless url.is_a?(URI)
      url = url + alt if alt
      url.fragment = nil # remove #x part of url
      url
    end

    def follow_links(url, doc)
      doc.css(link_path).each do |a|
        visit(uri(url, a["href"]))
      end
    end
  end
end
