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

    def run(chapters)
      outstanding = CascadingArray.new([], chapters.map { |o| uri(o) })
      visited = []

      while (url = outstanding.shift)
        contents, new_pages, new_chapters = visit_page(url)
        visited << contents
        new_pages.each do |href|
          outstanding.add_page(href) unless outstanding.include?(href) || invalid_urls.include?(href)
        end
        new_chapters.each do |href|
          outstanding.add_chapter(href) unless outstanding.include?(href) || invalid_urls.include?(href)
        end
      end
      visited
    end

    private

    # this one hangs on mutations
    def visit_page(url)
      logger.info { "visit #{url}" }
      page = web[url.to_s]
      doc = Nokogiri::HTML(page)
      [
        page,
        page_def.page_links(doc) { |a| uri(url, a["href"]) },
        page_def.chapter_links(doc) { |a| uri(url, a["href"]) }
      ]
    end

    # raises URI::Error (BadURIError)
    def uri(url, alt = nil)
      url = URI.parse(url) unless url.is_a?(URI)
      url += alt if alt
      url.fragment = nil # remove #x part of url
      url
    end
  end
end
