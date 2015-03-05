require 'uri'

module AudioBookCreator
  class UrlFilter
    include Logging
    attr_accessor :host

    def initialize(host)
      self.host = host
    end

    def host=(url)
      @host = url && (url.is_a?(URI) ? url : URI.parse(url)).host
    end

    # return true if this is invalid
    def include?(url)
      if !valid_extensions.include?(File.extname(url.path))
        logger.warn { "ignoring bad file extension #{url}" }
        raise "bad file extension"
      elsif host && (host != url.host)
        logger.warn { "ignoring remote url #{url}" }
        raise "remote url #{url}"
      end
    end

    private

    def valid_extensions
      ["", '.html', '.htm', '.php', '.jsp']
    end
  end
end
