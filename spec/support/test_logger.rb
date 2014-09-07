require "logger"
require "stringio"

class TestLogger
  def self.gen(level = nil)
    Logger.new(StringIO.new).tap do |logger|
      logger.formatter = proc do |severity, datetime, progname, msg|
        msg + "\n"
      end
      logger.level = Logger::WARN
    end
  end

  def self.result(logger)
    logger.instance_variable_get(:@logdev).dev.string
  end

  def self.results(logger)
    result(logger).split("\n")
  end
end
