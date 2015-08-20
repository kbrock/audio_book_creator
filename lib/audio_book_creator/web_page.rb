module AudioBookCreator
  class WebPage
    attr_accessor :url
    attr_accessor :body
    #attr_accessor :etag

    def initialize(url, body)
      @url = url
      @body = body
    end

    def empty?
      body.empty?
    end

    def css(path)
      dom.css(path).map {|n| n.text }
    end

    def dom
      @dom ||= Nokogiri::HTML(body)
    end

    def ==(other)
      other.kind_of?(WebPage) &&
        other.url.eql?(url) && other.body.eql?(body)
    end
    alias :eql? :==
  end
end
