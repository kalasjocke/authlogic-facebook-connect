module AuthlogicFacebookConnect
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
      end
    end
    
    module Config
      # TODO: Maybe make the facebook_uid field optional
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          validate :validate_by_facebook_connect, :if => :authenticating_with_facebook_connect?
        end
        
        def credentials=(value)
          # TODO: Is there a nicer way to tell Authlogic that we don't have any credentials than this?
          values = [:facebook_connect]
          
          super
        end
      end
      
      def validate_by_facebook_connect
        facebook_session = controller.facebook_session
        
        self.attempted_record = klass.find(:first, :conditions => {:facebook_uid => facebook_session.user.uid})
        
        unless self.attempted_record
          begin
            # Get the user from facebook and create a local user
            self.attempted_record = klass.new(
              :name => facebook_session.user.name,
              :facebook_uid => facebook_session.user.uid)
            
            # Save the user without validation as we may have validations for the user that are not met yet
            self.attempted_record.save(false)
          rescue Facebooker::Session::SessionExpired
            errors.add_to_base(I18n.t('error_messages.facebooker_session_expired', 
              :default => "Your Facebook Connect session has expired, please reconnect."))
          end
        end
      end
      
      def authenticating_with_facebook_connect?
        attempted_record.nil? && errors.empty? && controller.facebook_session
      end
      
    end
  end
end