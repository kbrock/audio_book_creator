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

end

require_relative "support/test_logger"

begin
  require "pry"
rescue LoadError
end

module SpecHelpers
  def link(url)
    %(<a href="#{url}">link</a>")
  end

  def page(title, *args)
    %(<html><head><title>#{title}</title></head>
      <body>#{Array(args).join(" ")}</body>
      </html>)
  end

  def uri(url)
    if url.is_a?(Array)
      url.map { |u| uri(u) }
    else
      URI.parse(site(url))
    end
  end

  def site(url)
    if url.is_a?(Array)
      url.map { |u| site(u) }
    else
      url.include?("http") ? url : "http://site.com/#{url}"
    end
  end

  def chapter(body, title = "the title", number = 1)
    AudioBookCreator::Chapter.new(number: number, title: title, body: body)
  end

  def verbose_logging
    AudioBookCreator.logger.level = Logger::INFO
  end

  def expect_to_log(*val)
    TestLogger.results(AudioBookCreator.logger).zip(Array(val).flatten) do |rslt, exp|
      expect(rslt).to match(exp)
    end
  end
end

SimpleCov.start unless ENV['MUTANT']

require 'audio_book_creator'

RSpec.configure do |c|
  c.include SpecHelpers
  c.before do
    AudioBookCreator.logger = TestLogger.gen
  end

  unless ENV['MUTANT']
    c.run_all_when_everything_filtered = true
    c.filter_run :focus
    c.order = 'random'
  end
end
