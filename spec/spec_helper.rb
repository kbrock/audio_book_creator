$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

begin
  require "pry"
rescue LoadError
end

module HtmlHelpers
  def link(url)
    %{<a href="#{url}">link</a>"}
  end

  def page(title, *args)
    %{<html><head><title>#{title}</title></head>
      <body>#{Array(args).join(" ")}</body>
      </html>}
  end
end

module Factories
  def chapter(body, title = "the title", number = 1)
    AudioBookCreator::Chapter.new(number: number, title: title, body: body)
  end
end

RSpec.configure do |c|
  c.include HtmlHelpers
  c.include Factories
end

begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'audio_book_creator'
