require 'open3'
# migrate to awesome spawn
module AudioBookCreator
  class Runner
    def run(cmd, options)
      options = options.dup
      verbose = options.delete(:verbose)
      params = options.delete(:params).flatten.flatten.compact

      log(verbose) { "run: #{cmd} #{params.join(" ")}" }
      log verbose, ""
      status = system(cmd, *params.map { |x| x.to_s })
      log verbose, ""
      log(verbose) { status == true ? "success" : "issue (return code #{status})" }

      status == true
    end

    def run!(cmd, options)
      run(cmd, options) || raise("trouble running command")
    end

    def log(verbose, msg = nil)
      puts(block_given? ? yield : msg) if verbose
    end
  end
end
