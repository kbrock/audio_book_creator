require 'nokogiri'
module AudioBookCreator
  class Editor
    attr_accessor :page_def
    attr_accessor :max_paragraphs
    attr_accessor :title_path
    attr_accessor :body_path

    def initialize(page_def)
      @page_def = page_def
    end

    def parse(pages)
      pages.each_with_index.map do |page, i|
        dom = Nokogiri::HTML(page)
        title = page_def.title(dom, "Chapter #{i + 1}")
        body = page_def.body(dom)
        Chapter.new(number: (i + 1), title: title, body: body)
      end
    end
  end
end
