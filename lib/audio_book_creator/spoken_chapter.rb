module AudioBookCreator
  class SpokenChapter
    attr_accessor :title, :filename

    def initialize(title, filename)
      @title = title
      @filename = filename
    end

    def ==(other)
      other.is_a?(SpokenChapter) &&
        other.title == title && other.filename == filename
    end
  end
end
