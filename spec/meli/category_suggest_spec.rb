require "spec_helper"

describe Meli::CategorySuggest do

  it "should site " do
    expect(Meli::CategorySuggest.site.to_s).to eq("http://syi.mercadolivre.com.br/category")
  end

  it "should collection_name" do
    expect(Meli::CategorySuggest.collection_name).to eq("suggest")
  end

  it "should scope_to_params" do
    scope   = "ipod"
    options = Meli::CategorySuggest.scope_to_params(scope, {})
    expect(options).to eql({ params: { q: "ipod" }})
  end

  it "should return all the suggested categories"
end
