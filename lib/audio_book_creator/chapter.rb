module AudioBookCreator
  class Chapter
    attr_accessor :book, :number, :title, :body

    def initialize(options = {})
      options.each { |n, v| self.send("#{n}=", v) }
      @body = Array(@body).compact.join("\n\n")
    end

    def filename
      "#{book}/chapter%02d" % number
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
