module AudioBookCreator
  class BookCreator
      # config: 
      # web (factory), page_def.link_path || outstanding[] -> pages[]
      #   decision (!invalid, !outstanding, !visited)
    attr_accessor :spider
      # page_def || pages -> chapters
    attr_accessor :editor
      # spoken_def, base_dir ||  chapter[] -> spoken_chapters[]
    attr_accessor :speaker
      # spoken_chapter[], book_def -> book
      # force, channels, max_hours, bit_rate, sample_rate
    attr_accessor :binder

    def initialize(spider, editor, speaker, binder)
      @spider  = spider
      @editor  = editor
      @speaker = speaker
      @binder  = binder
    end

    def create(outstanding)
      speaker.make_directory_structure
      binder.create(
        editor.parse(
          spider.run(outstanding)
        ).map { |chapter| speaker.say(chapter) }
      )
    end
  end
end
