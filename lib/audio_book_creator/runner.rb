# migrate to awesome spawn
module AudioBookCreator
  class Runner
    include Logging

    def run(cmd, options)
      params = options[:params].flatten.flatten.compact

      cmdline = [cmd] + params.map(&:to_s)

      logger.info { "run: #{cmdline.join(" ")}" }
      logger.info ""
      status = system(*cmdline)
      logger.info ""
      logger.info { status ? "success" : "issue" }

      status
    end

    def run!(cmd, options)
      run(cmd, options) || raise("trouble running command")
    end
  end
end
