# require "authlogic_facebook_connect/version"
require "authlogic_facebook_connect/acts_as_authentic"
require "authlogic_facebook_connect/session"
require "authlogic_facebook_connect/helper"

if ActiveRecord::Base.respond_to?(:add_acts_as_authentic_module)
  ActiveRecord::Base.send(:include, AuthlogicFacebookConnect::ActsAsAuthentic)
  Authlogic::Session::Base.send(:include, AuthlogicFacebookConnect::Session)
  ActionController::Base.helper AuthlogicFacebookConnect::Helper
end
