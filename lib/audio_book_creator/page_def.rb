module AudioBookCreator
  # information on the format of the html page that is read
  class PageDef
    attr_accessor :title_path, :body_path, :link_path, :chapter_path

    def initialize(title_path = "h1", body_path = "p", link_path = "a", chapter_path = nil)
      @title_path = title_path
      @body_path = body_path
      @link_path = link_path
      @chapter_path = chapter_path
    end

    def page_links(dom, &block)
      dom.css(link_path).map(&block)
    end

    def chapter_links(dom, &block)
      dom.css(chapter_path).map(&block)
    end
  end
end
