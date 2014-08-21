# migrate to awesome spawn
module AudioBookCreator
  class Runner
    def run(cmd, options)
      verbose = options[:verbose]
      params = options[:params].flatten.flatten.compact

      log(verbose) { "run: #{cmd} #{params.join(" ")}" }
      log verbose, ""
      status = system(cmd, *params.map { |x| x.to_s })
      log verbose, ""
      log(verbose) { status ? "success" : "issue" }

      status
    end

    def run!(cmd, options)
      run(cmd, options) || raise("trouble running command")
    end

    def log(verbose, msg = nil)
      puts(block_given? ? yield : msg) if verbose
    end
  end
end
