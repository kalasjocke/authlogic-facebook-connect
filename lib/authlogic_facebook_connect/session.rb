module AuthlogicFacebookConnect
  module Session
    def self.included(base)
      base.class_eval do
        extend Config
        include Methods
      end
    end
    
    module Config
    end
    
    module Methods
      def self.included(base)
        base.class_eval do
        end
      end
    end
  end
end