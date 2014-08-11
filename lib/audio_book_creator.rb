require "audio_book_creator/version"

module AudioBookCreator
  def self.sanitize_filename(*filenames)
    filenames.flatten.compact.join(".").gsub(/[^-._a-z0-9A-Z]/, "-").gsub(/--*/, "-").gsub(/-$/, "").downcase
  end

  def self.should_write?(filename, force = false)
    force || !File.exist?(filename)
  end
end

require "audio_book_creator/page_db"
require "audio_book_creator/chapter"
require "audio_book_creator/editor"
require "audio_book_creator/speaker"
require "audio_book_creator/runner"
require "audio_book_creator/binder"
require "audio_book_creator/spider"
