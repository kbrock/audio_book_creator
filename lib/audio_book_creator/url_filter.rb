require 'uri'

module AudioBookCreator
  class UrlFilter
    include Logging
    attr_accessor :host
    attr_accessor :ignore_bogus

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def host=(url)
      if url
        if url.is_a?(URI)
          @host = url.host
        else
          @host = URI.parse(url).host
        end
      else
        @host = nil
      end
    end

    # return true if this is invalid
    def include?(url)
      if !valid_extensions.include?(File.extname(url.path))
        logger.warn { "ignoring bad file extension #{url}" }
        raise "bad file extension" unless ignore_bogus
        true
      elsif host && (host != url.host)
        logger.warn { "ignoring remote url #{url}" }
        raise "remote url #{url}" unless ignore_bogus
        true
      # elsif already_visited(url)
      #   true
      end
    end

    private

    def valid_extensions
      ["", '.html', '.htm', '.php', '.jsp']
    end
  end
end
