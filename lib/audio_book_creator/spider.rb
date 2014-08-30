require 'nokogiri'
require 'open-uri'
require 'uri'

module AudioBookCreator
  class Spider
    # @!attribute visited
    #   @return Hash cache of all pages visited
    attr_accessor :cache

    # @!attribute outstanding
    #   @return Array<URI> the pages not visited yet
    attr_accessor :outstanding

    # @!attribute visited
    #   @return Array<URI> the pages visited
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

    # Add a url to the outstanding list of pages to visit
    def visit(url, alt = nil)
      url = uri(url, alt)
      url.fragment = nil # remove #x part of url
      @host_limit ||= url.host
      if want_to_visit_url(url)
        enqueue_url(url)
      end
    end

    def run
      while (url = next_item)
        ensure_under_limit
        log { "visit  #{url} [#{visited.size + 1}/#{max || "all"}]" }
        visit_page(url)
      end

      # currently returns array of blocks of html docs
      visited.map { |visited_url| cache[visited_url.to_s] }
    end

    private

    # limiter interface
    def ensure_under_limit
      raise "visited #{max} pages.\n  use --max to increase pages visited" if over_limit?
    end

    def over_limit?
      max && (visited.size >= (max+1))
    end

    # work list interface

    def enqueue_url(url) # call <<
      outstanding << url if !known(url)
    end

    def next_item
      outstanding.shift.tap { |url| visited << url if url }
    end

    # url is known, either visited or in the todo list
    def known(url)
      visited.include?(url) || outstanding.include?(url)
    end

    def want_to_visit_url(url)
      if !valid_extensions.include?(File.extname(url.path))
        raise "bad file extension" unless ignore_bogus
        log { "ignoring bad extension #{url}" }
      elsif (host_limit != url.host)
        raise "remote url #{url}" unless ignore_bogus
        log { "ignoring remote url #{url}" }
      else
        true
      end
    end

    def valid_extensions
      [nil, "", '.html', '.htm', '.php', '.jsp']
    end

    # raises URI::Error (BadURIError)
    def uri(url, alt = nil)
      url = URI.parse(url) unless url.is_a?(URI)
      alt && url ? url + alt : url
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
      unless (contents = cache[url_str])
        log { "fetch  #{url}" }
        contents ||= open(url_str).read
        cache[url_str] = contents
      end

      follow_links url, Nokogiri::HTML(contents)
    end
  end
end
