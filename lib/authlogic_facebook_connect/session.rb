module AuthlogicFacebookConnect
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
      end
    end

    module Config
      # Should the user be saved with our without validations?
      #
      # The default behavior is to save the user without validations and then
      # in an application specific interface ask for the additional user 
      # details to make the user valid as facebook just provides a facebook id.
      #
      # This is useful if you do want to turn on user validations, maybe if you 
      # just have facebook connect as an additional authentication solution and 
      # you already have valid users.
      # 
      # * <tt>Default:</tt> true
      # * <tt>Accepts:</tt> Boolean
      def facebook_valid_user(value = nil)
        rw_config(:facebook_valid_user, value, false)
      end
      alias_method :facebook_valid_user=, :facebook_valid_user

      # What user field should be used for the facebook UID?
      #
      # This is useful if you want to use a single field for multiple types of
      # alternate user IDs, e.g. one that handles both OpenID identifiers and
      # facebook ids.
      #
      # * <tt>Default:</tt> :facebook_uid
      # * <tt>Accepts:</tt> Symbol
      def facebook_uid_field(value = nil)
        rw_config(:facebook_uid_field, value, :facebook_uid)
      end
      alias_method :facebook_uid_field=, :facebook_uid_field
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

        self.attempted_record =
          klass.find(:first, :conditions => { facebook_uid_field => facebook_session.user.uid })

        unless self.attempted_record
          begin
            # Get the user from facebook and create a local user.
            #
            # We assign it after the call to new in case the attribute is protected.
            new_user = klass.new
            new_user.send(:"#{facebook_uid_field}=", facebook_session.user.uid)

            new_user.before_connect(facebook_session) if new_user.respond_to?(:before_connect)
            
            self.attempted_record = new_user
            
            if facebook_valid_user
              errors.add_to_base(
                I18n.t('error_messages.facebook_user_creation_failed',
                       :default => 'There was a problem creating a new user ' +
                                   'for your Facebook account')) unless self.attempted_record.valid?

              self.attempted_record = nil
            else
              self.attempted_record.save_with_validation(false)
            end
          rescue Facebooker::Session::SessionExpired
            errors.add_to_base(I18n.t('error_messages.facebooker_session_expired', 
              :default => "Your Facebook Connect session has expired, please reconnect."))
          end
        end
      end

      def authenticating_with_facebook_connect?
        controller.set_facebook_session
        attempted_record.nil? && errors.empty? && controller.facebook_session
      end

      private
        def facebook_valid_user
          self.class.facebook_valid_user
        end
      
        def facebook_uid_field
          self.class.facebook_uid_field
        end
    end
  end
end
