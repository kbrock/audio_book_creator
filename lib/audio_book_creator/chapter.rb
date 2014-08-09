module AudioBookCreator
  class Chapter
    attr_accessor :book, :number, :title, :body
    def initialize(book = nil, number = nil, title = nil, body = nil)
      @book   = book
      @number = number
      @title  = title
      @body   = Array(body).join("\n\n")
    end

    def filename(ext = "")
      "#{book}/chapter%02d%s" % [number, ext]
    end

    def empty?
      body.empty?
    end

    def to_s
      "#{title}\n\n#{body}\n"
    end

    def ==(other)
      other.is_a?(Chapter) &&
        other.book == book && other.number == number &&
        other.title == title && other.body == body
    end
  end
end
