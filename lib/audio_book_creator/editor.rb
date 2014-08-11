require 'nokogiri'
module AudioBookCreator
  class Editor
    attr_accessor :max_paragraphs
    attr_accessor :title_path
    attr_accessor :body_path

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def parse(pages)
      pages.each_with_index.map do |page, i|
        dom = Nokogiri::HTML(page)
        title = dom.css(title_path).first
        title = title ? title.text : "Chapter #{i + 1}"
        # map is not necessary, join will do the right thing, but this feels better...
        body = limit(dom.css(body_path)).map { |n| n.text }
        Chapter.new(number: (i + 1), title: title, body: body)
      end
    end

    def limit(nodes)
      max_paragraphs ? nodes.first(max_paragraphs) : nodes
    end
  end
end
