require 'nokogiri'
require 'open-uri'
require 'uri'

module AudioBookCreator
  class Spider
    # @!attribute visited
    #   @return Hash cache of all pages visited
    attr_accessor :cache
    attr_accessor :verbose

    attr_accessor :work_list
    attr_accessor :invalid_urls

    attr_accessor :link_path

    def initialize(cache = {}, work_list = [], invalid_urls = {}, options = {})
      @cache           = cache
      @work_list       = work_list
      @invalid_urls    = invalid_urls
      options.each { |n, v| public_send("#{n}=", v) }
    end

    # Add a url to the outstanding list of pages to visit
    def visit(url, alt = nil)
      url = uri(url, alt)
      self << url
    end

    def <<(url)
      @work_list << url unless @invalid_urls[url]
      self
    end

    def run
      while (url = @work_list.shift)
        log { "visit  #{url} "} #[#{@work_list.visited_counter}]" }
        visit_page(url)
      end

      # currently returns array of blocks of html docs
      #work_list.visited.map { |visited_url| cache[visited_url.to_s] }
    end

    private

    # raises URI::Error (BadURIError)
    def uri(url, alt = nil)
      url = URI.parse(url) unless url.is_a?(URI)
      url = url + alt if alt
      url.fragment = nil # remove #x part of url
      url
    end

    def follow_links(url, doc)
      doc.css(link_path).each do |a|
        visit(url, a["href"])
      end
    end

    def log(str = nil)
      puts(str || yield) if verbose
    end

    def visit_page(url)
      url_str = url.to_s
      unless (contents = @cache[url_str])
        log { "fetch  #{url}" }
        contents ||= open(url_str).read
        @cache[url_str] = contents
      end

      follow_links url, Nokogiri::HTML(contents)
    end
  end
end
