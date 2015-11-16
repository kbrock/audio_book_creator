module AudioBookCreator
  # information on the format of the html page that is read
  class PageDef
    attr_accessor :title_path, :body_path, :link_path, :chapter_path
    attr_accessor :invalid_urls

    def initialize(title_path = "h1", body_path = "p", link_path = "a", chapter_path = nil, invalid_urls = {})
      @title_path = title_path
      @body_path = body_path
      @link_path = link_path
      @chapter_path = chapter_path
      @invalid_urls = invalid_urls
    end

    def page_links(page)
      page.links(link_path).select { |href| !invalid_urls.include?(href) }
    end

    def chapter_links(page)
      page.links(chapter_path).select { |href| !invalid_urls.include?(href) }
    end
  end
end
