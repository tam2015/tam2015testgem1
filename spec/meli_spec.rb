require "spec_helper"

describe Meli do

  it "should return default configs" do
    expect(Meli.config).to eq( default_config )
  end

  it "should set app_key" do
    Meli.config.app_key = "ASKJNASDNAS90DSA9JDAS8D9AD98"
    expect(Meli.config.app_key).to eq( "ASKJNASDNAS90DSA9JDAS8D9AD98" )

    Meli.config.app_key = nil
    expect(Meli.config.app_key).to be_nil
  end


  # Helpers
  def default_config
    {
      :client_id            => nil,
      :client_secret        => nil,
      :callback_url         => nil,
      :client_id            => nil,
      :client_secret        => nil,

      :site_id              => "MLB",
      :site                 => "https://api.mercadolibre.com",
      :authorize_url        => "http://auth.mercadolivre.com.br/authorization",
      :token_url            => "/oauth/token",
      :after_refresh_token  => nil
    }
  end
end
