$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

begin
require 'simplecov'
SimpleCov.start
rescue LoadError
end

require 'audio_book_creator'
