require 'nokogiri'
require 'open-uri'
require 'uri'

module AudioBookCreator
  class Spider
    # @!attribute visited
    #   @return Hash cache of all pages visited
    attr_accessor :cache

    attr_accessor :work_list

    attr_accessor :verbose

    attr_accessor :ignore_bogus

    attr_accessor :link_path

    attr_accessor :host_limit

    def initialize(cache = {}, work_list = [], options = {})
      @cache           = cache
      @work_list       = work_list
      options.each { |n, v| public_send("#{n}=", v) }
    end

    # Add a url to the outstanding list of pages to visit
    def visit(url, alt = nil)
      url = uri(url, alt)
      url.fragment = nil # remove #x part of url
      @host_limit ||= url.host
      if want_to_visit_url(url)
        @work_list << url
      end
    end

    def run
      while (url = @work_list.shift)
        log { "visit  #{url} [#{@work_list.visited_counter}]" }
        visit_page(url)
      end

      # currently returns array of blocks of html docs
      #work_list.visited.map { |visited_url| cache[visited_url.to_s] }
    end

    private

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
      unless (contents = @cache[url_str])
        log { "fetch  #{url}" }
        contents ||= open(url_str).read
        @cache[url_str] = contents
      end

      follow_links url, Nokogiri::HTML(contents)
    end
  end
end
