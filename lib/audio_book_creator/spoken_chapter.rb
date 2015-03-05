module AudioBookCreator
  class SpokenChapter
    attr_accessor :title, :filename

    def initialize(title, filename)
      @title = title
      @filename = filename
    end

    def ==(other)
      other.kind_of?(SpokenChapter) &&
        other.title.eql?(title) && other.filename.eql?(filename)
    end
    alias :eql? :==
  end
end
