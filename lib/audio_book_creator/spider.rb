require 'nokogiri'
require 'open-uri'

module AudioBookCreator
  class Spider
    # @!attribute visited
    #   @return Hash cache of all pages visited
    attr_accessor :cache
    # @!attribute visited
    #   @return Array<String> the pages visited
    attr_accessor :visited

    attr_accessor :verbose
    # @!attribute max
    #   @return Numeric max number of pages to visit
    attr_accessor :max

    def initialize(cache = {}, options = {})
      @cache = cache
      @outstanding = []
      @visited = []
      @verbose = options[:verbose]
      @max             = options[:max]
    end

    # Add a url to visit
    # note: this is called by the block yielded by visit to properly spider
    def visit(urls)
      log { "queue url #{urls}" }
      @outstanding += Array(urls).map {|url| url.split("#").first }.uniq.delete_if { |url| visited.include?(url) }
      raise "too many pages" if max && (visited.size + @outstanding.size) > max
    end

    def run(link = "a", &block)
      block = basic_spider(link) unless block_given?
      while url = @outstanding.shift
        unless visited.include? url
          log { "visiting url #{url}" }
          visited << url
          visit_page(url, &block)
        end
      end
    end

    private

    def basic_spider(link)
      lambda do |doc, spider|
        doc.css(link).each do |a|
          spider.visit(a["href"])
        end
      end
    end

    def log(str = nil)
      if verbose
        puts str if str
        puts yield if block_given?
      end
    end

    def visit_page(url)
      contents = open(url)
      cache[url] = contents
      yield Nokogiri::HTML(contents), self if block_given?
    end
  end
end