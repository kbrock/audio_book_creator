module AudioBookCreator
  # information on the format of the html page that is read
  class PageDef
    attr_accessor :title_path, :body_path, :link_path, :chapter_path, :max_paragraphs

    def initialize(title_path = "h1", body_path = "p", link_path = "a", chapter_path = nil, max_paragraphs = nil)
      @title_path = title_path
      @body_path = body_path
      @link_path = link_path
      @chapter_path = chapter_path
      @max_paragraphs = max_paragraphs
    end

    def title(dom)
      title = dom.css(title_path).first
      title.text if title
    end

    def body(dom)
      limit(dom.css(body_path))
      # feels like I need .map { |n| n.text }
    end

    def page_links(dom, &block)
      dom.css(link_path).map(&block)
    end

    def chapter_links(dom, &block)
      dom.css(chapter_path).map(&block)
    end

    private

    def limit(nodes)
      max_paragraphs ? nodes.first(max_paragraphs) : nodes
    end
  end
end
