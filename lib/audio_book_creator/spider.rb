module AudioBookCreator
  class Spider
    include Logging

    # @!attribute web
    #   @return Hash access to the world wide web
    attr_accessor :web
    attr_accessor :invalid_urls

    attr_accessor :page_def

    def initialize(page_def, web, invalid_urls)
      @page_def     = page_def
      @web          = web
      @invalid_urls = invalid_urls
    end

    def run(chapters)
      outstanding = CascadingArray.new([], WebPage.map_urls(chapters))
      visited = []

      while (url = outstanding.shift)
        contents, new_pages, new_chapters = visit_page(url)
        visited << contents
        new_pages.each do |href|
          outstanding.add_unique_page(href) unless invalid_urls.include?(href)
        end
        new_chapters.each do |href|
          outstanding.add_unique_chapter(href) unless invalid_urls.include?(href)
        end
      end
      visited
    end

    private

    # this one hangs on mutations
    def visit_page(url)
      logger.info { "visit #{url}" }
      page = web[url.to_s]
      wp = WebPage.new(url, page)
      [
        wp,
        page_def.page_links(wp),
        page_def.chapter_links(wp)
      ]
    end
  end
end
