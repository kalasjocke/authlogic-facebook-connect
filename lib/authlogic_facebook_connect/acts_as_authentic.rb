module AuthlogicFacebookConnect
  module ActsAsAuthentic
    def self.included(base)
      base.class_eval do
        extend Config
        
        add_acts_as_authentic_module(Methods, :prepend)
      end
    end
    
    module Config
    end
    
    module Methods
      def self.included(base)
        base.class_eval do
          # validations
        end
      end
    end
  end
end