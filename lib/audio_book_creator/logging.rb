module AudioBookCreator
  module Logging

    def verbose=(val)
      AudioBookCreator.verbose = val
    end

    def log(str = nil, &block)
      AudioBookCreator.logger.warn(str, &block)
    end
    
    def self.included(base)
      base.send(:attr_accessor, :verbose)
    end
  end
end
