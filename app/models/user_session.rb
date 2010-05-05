class UserSession < Authlogic::Session::Base
  def self.oauth_consumer
    OAuth::Consumer.new(APP_CONFIG['api_key'], APP_CONFIG['secret_key'],
    { :site=>"https://api.linkedin.com",
      :scheme => :header,
      :request_token_url => 'https://api.linkedin.com/uas/oauth/requestToken',
      :access_token_url => 'https://api.linkedin.com/uas/oauth/accessToken',
      :authorize_url => "https://api.linkedin.com/uas/oauth/authorize" })
  end
end