# migrate to awesome spawn
module AudioBookCreator
  class Runner
    include Logging

    def initialize(options = {})
      options.each { |n, v| public_send("#{n}=", v) }
    end

    def run(cmd, options)
      params = options[:params].flatten.flatten.compact

      logger.info { "run: #{cmd} #{params.join(" ")}" }
      logger.info ""
      status = system(cmd, *params.map { |x| x.to_s })
      logger.info ""
      logger.info { status ? "success" : "issue" }

      status
    end

    def run!(cmd, options)
      run(cmd, options) || raise("trouble running command")
    end
  end
end
