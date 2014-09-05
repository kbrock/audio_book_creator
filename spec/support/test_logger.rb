require "logger"
require "stringio"

class TestLogger
  def self.gen(level = nil)
    logger = Logger.new(StringIO.new)
    logger.formatter = proc do |severity, datetime, progname, msg|
      msg
    end
    logger.level = level if level
    logger
  end

  def self.result(logger)
    logger.instance_variable_get(:@logdev).dev.string
  end

  def self.results(logger)
    result(logger).split("\n")
  end
end
