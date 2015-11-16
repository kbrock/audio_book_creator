require 'nokogiri'
require 'uri'

module AudioBookCreator
  class WebPage
    attr_accessor :url
    attr_accessor :body
    #attr_accessor :etag

    def initialize(url, body)
      @url = url
      @body = body
    end

    # def single_css(path) ; css(path).first ; end
    def css(path)
      dom.css(path).map {|n| n.text }
    end

    def links(path)
      dom.css(path).map { |a| self.class.uri(url, a["href"]) }
    end

    def dom
      @dom ||= Nokogiri::HTML(body)
    end
    private :dom

    def ==(other)
      other.kind_of?(WebPage) &&
        other.url.eql?(url)
    end
    alias :eql? :==

    def self.map_urls(url)
      url.map { |o| uri(o) }
    end

    private

    # raises URI::Error (BadURIError)
    def self.uri(url, alt = nil)
      url = URI.parse(url) unless url.is_a?(URI)
      url += alt if alt
      url.fragment = nil # remove #x part of url
      url
    end
  end
end
