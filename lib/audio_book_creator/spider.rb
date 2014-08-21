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

    attr_accessor :ignore_bogus

    attr_accessor :link_path

    attr_accessor :host_limit

    def initialize(cache = {}, options = {})
      @cache           = cache
      @outstanding     = []
      @visited         = []
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def over_limit?
      max && (visited.size >= max)
    end

    # Add a url to the outstanding list of pages to visit
    def visit(url)
      @host_limit ||= URI.parse(url).host
      if visited.include?(url) || outstanding.include?(url)
        # log { "ignore #{url}" }
      else
        log { "queue  #{url}" }
        outstanding << url
      end
    end

    def visit_relative_page(page_url, href)
      # alt: URI.parse(root).merge(URI.parse(href)).to_s
      if (absolute_href = local_href(page_url, href))
        visit(absolute_href)
      else
        raise "throwing away too much" unless ignore_bogus
        log { "throwing away #{href}" }
      end
    end

    def local_href(page_url, href)
      if (ref = URI.join(page_url, href))
        if (host_limit == ref.host) &&
          valid_extensions.include?(File.extname(ref.path))
          ref.fragment = nil # remove #x part of url
          ref.to_s
        end
      end
    rescue URI::BadURIError
      # join 2 relative urls
    end

    def run
      while (url = outstanding.shift)
        raise "visited #{max} pages.\n  use --max to increase pages visited" if over_limit?
        log { "visit  #{url} [#{visited.size + 1}/#{max || "all"}]" }
        visited << url
        visit_page(url)
      end

      # currently returns array of blocks of html docs
      visited.map { |visited_url| cache[visited_url] }
    end

    private

    def valid_extensions
      [nil, "", '.html', '.htm', '.php', '.jsp']
    end

    def follow_links(url, doc)
      doc.css(link_path).each do |a|
        visit_relative_page(url, a["href"])
      end
    end

    def log(str = nil)
      puts(str || yield) if verbose
    end

    def visit_page(url)
      unless (contents = cache[url])
        log { "fetch  #{url}" }
        contents ||= open(url).read
        cache[url] = contents
      end

      follow_links url, Nokogiri::HTML(contents)
    end
  end
end
