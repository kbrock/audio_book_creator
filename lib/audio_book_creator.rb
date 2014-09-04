require "audio_book_creator/version"

module AudioBookCreator
  def self.sanitize_filename(*filenames)
    filenames.compact.join(".").gsub(/[^-._a-z0-9A-Z]/, "-").gsub(/--*/, "-").sub(/-$/, "")
  end

  def self.should_write?(filename, force = nil)
    force || !File.exist?(filename)
  end
end

require "audio_book_creator/logging"
require "audio_book_creator/page_db"
require "audio_book_creator/chapter"
require "audio_book_creator/editor"
require "audio_book_creator/speaker"
require "audio_book_creator/runner"
require "audio_book_creator/binder"
require "audio_book_creator/url_filter"
require "audio_book_creator/work_list"
require "audio_book_creator/array_with_max_feedback"
require "audio_book_creator/spider"
