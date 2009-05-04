# require "authlogic_facebook_connect/version"
require "authlogic_facebook_connect/acts_as_authentic"
require "authlogic_facebook_connect/session"

ActiveRecord::Base.send(:include, AuthlogicFacebookConnect::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicFacebookConnect::Session)