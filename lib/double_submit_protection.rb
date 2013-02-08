require "double_submit_protection/version"

module DoubleSubmitProtection

  DEFAULT_TOKEN_NAME = 'submit_token'

  module View
    def double_submit_token_hash(id, token_name=nil)
      key = DoubleSubmitProtection.token_key(id, token_name)
      @double_submit_token_hash ||= {}
      @double_submit_token_hash[key] ||=
        begin
          key = DoubleSubmitProtection.token_key(id, token_name)
          value = token_value()
          flash[key] = value
          value
        end
      { key => @double_submit_token_hash[key] }
    end

    def double_submit_token(id, token_name=nil)
      h = double_submit_token_hash(id, token_name)
      hidden_field_tag(h.keys.first, h.values.first)
    end

    private

    def token_value
      Digest::MD5.hexdigest(rand.to_s)
    end
  end

  module Controller
    def double_submit?(id, token_name=nil)
      key = DoubleSubmitProtection.token_key(id, token_name)
      token = flash[key]
      token.nil? || (token != params[key])
    end
  end

  def self.token_key(id, name=nil)
    name &&= "_#{name}"
    "#{DEFAULT_TOKEN_NAME}#{name}:#{id}"
  end

end

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.class_eval do
    include DoubleSubmitProtection::Controller
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Base.class_eval do
    include DoubleSubmitProtection::View
  end
end
