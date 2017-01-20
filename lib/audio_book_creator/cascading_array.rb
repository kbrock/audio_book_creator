require 'set'

module AudioBookCreator
  # this fetching from the first array, fetching from the second if nothing is available
  class CascadingArray
    include Enumerable

    # @!attribute main
    #   @return Array the alternative array if this one is empty
    attr_accessor :main

    # @!attribute alt
    #   @return Array the alternative array if this one is empty
    attr_accessor :alt

    attr_accessor :all

    def initialize(main, alt)
      @all = Set.new.merge(main).merge(alt)
      @main = main
      @alt = alt
    end

    def add_chapter(value)
      all << value
      alt << value
    end

    def add_unique_chapter(value)
      add_chapter(value) unless include?(value)
    end

    def add_page(value)
      all << value
      main << value
    end

    def add_unique_page(value)
      add_page(value) unless include?(value)
    end

    def each(&block)
      return enum_for unless block_given?
      main.each(&block)
      alt.each(&block)
    end

    # note: ever included
    def include?(value)
      all.include?(value)
    end

    def shift
      main.shift || alt.shift
    end
  end
end
