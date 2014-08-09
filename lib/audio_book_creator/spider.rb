require 'nokogiri'
require 'open-uri'
require 'uri'

module AudioBookCreator
  class Spider
    # @!attribute visited
    #   @return Hash cache of all pages visited
    attr_accessor :cache

    # @!attribute outstanding
    #   @return Array<String> the pages not visited yet
    attr_accessor :outstanding

    # @!attribute visited
    #   @return Array<String> the pages visited
    attr_accessor :visited

    attr_accessor :verbose
    # @!attribute max
    #   @return Numeric max number of pages to visit
    attr_accessor :max

    def initialize(cache = {}, options = {})
      @cache           = cache
      @outstanding     = []
      @visited         = []
      @verbose         = options[:verbose]
      @max             = options[:max]
      @starting_host   = options[:multi_site]
    end

    def multi_site?
      @starting_host == true
    end

    # Add a url to visit
    # note: this is called by the block yielded by visit to properly spider
    # using loop to dedup urls
    def visit(urls)
      Array(urls).each do |url|
        @starting_host ||= URI.parse(url).host
        if visited.include?(url) || outstanding.include?(url)
          # log { "ignore #{url}" }
        else
          log { "queue  #{url}" }
          outstanding << url
        end
      end

      self
    end

    def visit_relative_page(page_url, href)
      # alt: URI.parse(root).merge(URI.parse(href)).to_s
      if absolute_href = local_href(page_url, href)
        visit(absolute_href)
      else
        log { "throwing away #{href}" }
      end
    end

    def local_href(page_url, href)
      if (ref = URI.join(page_url, href) rescue nil)
        if (multi_site? || @starting_host == ref.host) &&
          [nil, "", '.html', '.htm', '.php', '.jsp'].include?(File.extname(ref.path))
           ref.fragment = nil # remove #x part of url
           ref.to_s
        end
      end
    end

    def run(link = "a", &block)
      block = basic_spider(link) unless block_given?

      while (url = outstanding.shift)
        if max && (visited.size >= max)
          raise "visited #{max} pages.\n  use --max to increase pages visited"
        end

        log { "visit  #{url} [#{visited.size + 1}/#{max || "all"}]" }
        visited << url
        visit_page(url, &block)
      end

      # currently returns array of blocks of html docs
      visited.map { |visited_url| cache[visited_url] }
    end

    private

    def basic_spider(link)
      lambda do |url, doc, spider|
        doc.css(link).each do |a|
          spider.visit_relative_page(url, a["href"])
        end
      end
    end

    def log(str = nil)
      puts str || yield if verbose
    end

    def visit_page(url)
      if contents = cache[url]
        # log { "cache  #{url}" }
      else
        log { "fetch  #{url}" }
        contents ||= open(url).read
        cache[url] = contents
      end

      yield url, Nokogiri::HTML(contents), self if block_given?
    end
  end
end
