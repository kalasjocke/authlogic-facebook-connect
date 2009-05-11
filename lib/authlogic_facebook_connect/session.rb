module AuthlogicFacebookConnect
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
      end
    end

    module Config
      # What user field should be used for the facebook UID?
      #
      # This is useful if you want to use a single field for multiple types of
      # alternate user IDs, e.g. one that handles both OpenID identifiers and
      # facebook ids.
      #
      # * <tt>Default:</tt> :facebook_uid
      # * <tt>Accepts:</tt> Symbol
      def facebook_uid_field(value = nil)
        config(:facebook_uid_field, value, :facebook_uid)
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
            # Get the user from facebook and create a local user
            self.attempted_record = klass.new(
              facebook_uid_field => facebook_session.user.uid)

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

      private
      def facebook_uid_field
        self.class.facebook_uid_field
      end
    end
  end
end
