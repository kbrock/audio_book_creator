$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

unless ENV['MUTANT']
  require "coveralls"
  require "simplecov"
  require "codeclimate-test-reporter"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    Coveralls::SimpleCov::Formatter,
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
  ]

  begin
    require "pry"
  rescue LoadError
  end
end

module HtmlHelpers
  def link(url)
    %(<a href="#{url}">link</a>")
  end

  def page(title, *args)
    %(<html><head><title>#{title}</title></head>
      <body>#{Array(args).join(" ")}</body>
      </html>)
  end

  # site helpers

  def expect_spider_to_visit_page(spider, url, *args)
    expect(spider).to receive(:open).with(url).once.and_return(double(read: page(url, *args)))
  end
end

module Factories
  def chapter(body, title = "the title", number = 1)
    AudioBookCreator::Chapter.new(number: number, title: title, body: body)
  end
end

SimpleCov.start unless ENV['MUTANT']

require 'audio_book_creator'

RSpec.configure do |c|
  c.include HtmlHelpers
  c.include Factories
  unless ENV['MUTANT']
    c.run_all_when_everything_filtered = true
    c.filter_run :focus
    c.order = 'random'
  end
end
