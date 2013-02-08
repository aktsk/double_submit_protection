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
          DoubleSubmitProtection::Config.token_store.write(key, value)
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
      token = DoubleSubmitProtection::Config.token_store.delete(key)
      token.nil? || (token != params[key])
    end
  end

  def self.token_key(id, name=nil)
    name &&= "_#{name}"
    "#{DEFAULT_TOKEN_NAME}#{name}:#{id}"
  end

  # DoubleSubmitProtection::Config.setup do
  #   write_method do |key, value|
  #     Rails.cache.write(key, value)
  #   end
  #   delete_method do |key|
  #     Rails.cache.read(key).tap do
  #       Rails.cache.write(key, nil)
  #     end
  #   end
  # end

  class Config
    class << self
      attr_reader :token_store

      def setup(&block)
        @token_store = self.new.tap do |e|
          e.instance_eval(&block)
        end
      end
    end

    private

    def write_method(&block)
      define_singleton_method :write, &block
    end

    def delete_method(&block)
      define_singleton_method :delete, &block
    end
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
