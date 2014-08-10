require 'nokogiri'
module AudioBookCreator
  class Editor
    attr_accessor :max_paragraphs
    attr_accessor :content

    def initialize(options = {})
      options.each { |n, v| self.public_send("#{n}=",v) }
    end

    def parse(book, pages)
      pages.each_with_index.map do |page, i|
        dom = Nokogiri::HTML(page)
        title = dom.css('h1').first.text
        body = limit(dom.css(content)).map { |n| n.text }.compact
        AudioBookCreator::Chapter.new(book: book, number: (i + 1), title: title, body: body)
      end
    end

    def limit(nodes)
      max_paragraphs ? nodes.first(max_paragraphs) : nodes
    end
  end
end
