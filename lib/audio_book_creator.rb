require "audio_book_creator/version"
require "logger"

module AudioBookCreator
  def self.sanitize_filename(*filenames)
    filenames.compact.join(".").gsub(/[^-._a-z0-9A-Z]/, "-").gsub(/--*/, "-").sub(/-$/, "")
  end

  def self.should_write?(filename, force = nil)
    force || !File.exist?(filename)
  end

  def self.logger=(val)
    @log = val
  end

  def self.logger
    @log ||= Logger.new(STDOUT).tap { |log| log.level = Logger::WARN }
  end
end

require "audio_book_creator/logging"
require "audio_book_creator/cached_hash"
require "audio_book_creator/cascading_array"
require "audio_book_creator/page_db"
require "audio_book_creator/chapter"
require "audio_book_creator/editor"
require "audio_book_creator/speaker"
require "audio_book_creator/runner"
require "audio_book_creator/web"
require "audio_book_creator/binder"
require "audio_book_creator/url_filter"
require "audio_book_creator/array_with_cap"
require "audio_book_creator/spider"
