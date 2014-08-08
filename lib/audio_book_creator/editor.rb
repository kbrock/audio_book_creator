require 'nokogiri'
module AudioBookCreator
  class Editor
    attr_accessor :max_lines

    def initialize
      @max_lines = 2
    end

    def parse(pages)
      pages.first(1).map do |page|
        dom = Nokogiri::HTML(page)
        title = dom.css('h1').first.text
        body = dom.css('#story p').first(3).map { |n| n }.join("\n\n")
        AudioBookCreator::Chapter.new(title, body)
      end
    end

    def limit(nodes)
      max_lines ? nodes.first(max_lines) : nodes
    end
  end
end
