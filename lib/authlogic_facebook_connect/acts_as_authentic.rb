module AuthlogicFacebookConnect
  module ActsAsAuthentic
    def self.included(klass)
      klass.class_eval do
        extend Config
        add_acts_as_authentic_module(Methods, :prepend)
      end
    end
    
    module Config
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
        end
      end
    end
  end
end