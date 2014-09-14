module AudioBookCreator
  # information on how the page is defined in the database
  class PageDef
    attr_accessor :url, :title_path, :body_path, :link_path, :max_paragraphs
    def initialize(url = nil, title_path = "h1", body_path = "p", link_path = "a", max_paragraphs = nil)
      @url = url
      @title_path = title_path
      @body_path = body_path
      @link_path = link_path
      @max_paragraphs = max_paragraphs
    end

    def title(dom, default_title)
      title = dom.css(title_path).first
      title = title ? title.text : default_title
    end

    def body(dom)
      limit(dom.css(body_path))
      # feels like I need .map { |n| n.text }
    end

    def links(dom, &block)
      dom.css(link_path).each(&block)
    end

    private

    def limit(nodes)
      max_paragraphs ? nodes.first(max_paragraphs) : nodes
    end
  end
end
