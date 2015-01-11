require "audio_book_creator/version"
require "logger"

module AudioBookCreator
  def self.should_write?(filename, force = nil)
    force || !File.exist?(filename)
  end

  def self.optionally_write(filename, force = nil)
    if should_write?(filename, force)
      File.write(filename, yield)
    end
  end

  def self.optionally_run(filename, force = nil)
    if should_write?(filename, force)
      Runner.new.run!(*yield)
    end
  end

  def self.logger=(val)
    @log = val
  end

  def self.logger
    @log ||= Logger.new(STDOUT).tap { |log| log.level = Logger::WARN }
  end
end

# general classes
require "audio_book_creator/cached_hash"
require "audio_book_creator/cascading_array"
require "audio_book_creator/logging"
require "audio_book_creator/runner"

# data config objects
require "audio_book_creator/book_def"
require "audio_book_creator/page_def"
require "audio_book_creator/speaker_def"

# data models
require "audio_book_creator/chapter"
require "audio_book_creator/spoken_chapter"

# web surfing objects
require "audio_book_creator/web"
require "audio_book_creator/url_filter"
require "audio_book_creator/page_db"
require "audio_book_creator/spider"

# business logic
# reformat
require "audio_book_creator/editor"
# flow
require "audio_book_creator/speaker"
require "audio_book_creator/binder"
