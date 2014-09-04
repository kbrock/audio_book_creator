require 'uri'

module AudioBookCreator
  class UrlFilter
    attr_accessor :host
    attr_accessor :ignore_bogus
    attr_accessor :verbose

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
        raise "bad file extension" unless ignore_bogus
        log { "ignoring bad file extension #{url}" }
        true
      elsif host && (host != url.host)
        raise "remote url #{url}" unless ignore_bogus
        log { "ignoring remote url #{url}" }
        true
      # elsif already_visited(url)
      #   true
      end
    end
    alias_method :[], :include?

    private

    def valid_extensions
      ["", '.html', '.htm', '.php', '.jsp']
    end

    def log
      puts(yield) if verbose
    end
  end
end
