require 'forwardable'
module AudioBookCreator
  class Defaulter
    extend Forwardable

    ATTRIBUTES = [:title_path, :body_path, :link_path, :chapter_path]
    def_delegators :page_def, *ATTRIBUTES, *ATTRIBUTES.map { |a| "#{a}="}

    attr_accessor :page_def
    attr_accessor :book_def
    attr_writer   :settings

    def initialize(page_def, book_def)
      @page_def    = page_def
      @book_def    = book_def
    end

    def host
      url = book_def.urls.first
      url && URI.parse(url).host
    end

    def settings
      # in the future, move into pages
      @settings ||= PageDb.new("pages.db", "settings", true)
    end

    def load_unset_values
      value = host && settings[host]
      value.each { |n, v| public_send("#{n}=", v) } if value
    end

    def store
      return unless host
      settings[host] = ATTRIBUTES.each_with_object(settings[host] || {}) do |attr, h|
        v = public_send(attr)
        h[attr] = v if v
      end
    end
  end
end
