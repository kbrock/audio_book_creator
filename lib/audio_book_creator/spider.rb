module AudioBookCreator
  class Spider
    include Logging

    # @!attribute web
    #   @return Hash access to the world wide web
    attr_accessor :web

    attr_accessor :page_def

    def initialize(page_def, web)
      @page_def     = page_def
      @web          = web
    end

    def run(chapters)
      outstanding = CascadingArray.new([], WebPage.map_urls(chapters))
      visited = []

      while (url = outstanding.shift)
        wp = visit_page(url)
        visited << wp
        page_def.page_links(wp).each do |href|
          outstanding.add_unique_page(href)
        end
        page_def.chapter_links(wp).each do |href|
          outstanding.add_unique_chapter(href)
        end
      end
      visited
    end

    private

    # this one hangs on mutations
    def visit_page(url)
      logger.info { "visit #{url}" }
      WebPage.new(url, web[url.to_s])
    end
  end
end
