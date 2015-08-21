require 'nokogiri'
module AudioBookCreator
  class Editor
    attr_accessor :page_def

    def initialize(page_def)
      @page_def = page_def
    end

    # convert page[] -> chapter[]
    def parse(pages)
      pages.each_with_index.map do |page, i|
        title = page.css(page_def.title_path).first || "Chapter #{i + 1}"
        body = page.css(page_def.body_path)
        Chapter.new(number: (i + 1), title: title, body: body)
      end
    end
  end
end
