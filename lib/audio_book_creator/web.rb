require 'open-uri'
require 'uri'

module AudioBookCreator
  class Web
    include Logging

    def [](url)
      logger.info { "fetch  #{url}" }
      open(url.to_s).read
    end
  end
end
