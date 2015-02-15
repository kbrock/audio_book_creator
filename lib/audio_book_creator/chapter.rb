module AudioBookCreator
  class Chapter
    attr_accessor :number, :title, :body

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
      @body = Array(@body).compact.join("\n\n")
    end

    def filename
      format("chapter%02d", number)
    end

    def empty?
      body.empty?
    end

    def present?
      !empty?
    end

    def to_s
      "#{title}\n\n#{body}\n"
    end

    def ==(other)
      other.is_a?(Chapter) &&
        other.number == number &&
        other.title == title && other.body == body
    end
  end
end
