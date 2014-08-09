require 'nokogiri'
module AudioBookCreator
  class Editor
    attr_accessor :max_lines

    def initialize(options = {})
      options.each { |n, v| self.public_send("#{n}=",v) }
    end

    def parse(book, pages)
      pages.each_with_index.map do |page, i|
        dom = Nokogiri::HTML(page)
        title = dom.css('h1').first.text
        body = limit(dom.css('#story p')).map { |n| n.text }
        AudioBookCreator::Chapter.new(book, i + 1, title, body)
      end
    end

    def limit(nodes)
      max_lines ? nodes.first(max_lines) : nodes
    end
  end
end
