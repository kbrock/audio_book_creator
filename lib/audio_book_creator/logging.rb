module AudioBookCreator
  module Logging
    def logger
      AudioBookCreator.logger
    end
    
    def self.included(base)
      base.send(:attr_accessor, :verbose)
    end
  end
end
