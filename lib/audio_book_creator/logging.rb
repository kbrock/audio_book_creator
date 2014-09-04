module AudioBookCreator
  module Logging
    def log(str = nil)
      puts(str || yield) if verbose
    end
    
    def self.included(base)
      base.send(:attr_accessor, :verbose)
    end
  end
end
