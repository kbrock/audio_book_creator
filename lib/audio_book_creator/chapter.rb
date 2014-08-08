module AudioBookCreator
  class Chapter
    attr_accessor :title, :body
    def initialize(title = nil, body = nil)
      @title = title
      @body  = body
    end

    def ==(other)
      other.is_a?(Chapter) && other.title == title && other.body == body
    end
  end
end
