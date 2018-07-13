module AudioBookCreator
  class Chapter
    attr_accessor :number, :title, :body

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
      @body = Array(body).compact.join("\n\n")
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

    def fixed_body
      # some webpages are encoded differently
      # [194, 151] ==> u0097
      # .gsub(/\u0091/, '\'')
      # .gsub(/\x93/,   '"')
      # .gsub(/\u0093/, '"')
      # .gsub(/\u0094/, '"')
      # .gsub(/\u0096/, '-')
      # .gsub(/\x97/,   '-')
      # .gsub(/\u0097/, '-')
      body.encode("UTF-8", invalid: :replace, undef: :replace, replace: '-')
          .gsub(/^[+#*-=_]{3,}/, '---')
    end

    def to_s
      "#{title}\n\n#{fixed_body}\n"
    end

    def ==(other)
      other.kind_of?(Chapter) &&
        other.number == number &&
        other.title.eql?(title) && other.body.eql?(body)
    end
    alias :eql? :==
  end
end
