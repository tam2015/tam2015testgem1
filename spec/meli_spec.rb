require "spec_helper"

describe Meli do

  it "should return default configs" do
    expect(Meli.config).to eq( default_config )
  end


  # Helpers
  def default_config
    {
      :site_id=>"MLB",
      :endpoint_url=>"https://api.mercadolibre.com",
      :auth_url=>"http://auth.mercadolivre.com.br/authorization"
    }
  end
end
