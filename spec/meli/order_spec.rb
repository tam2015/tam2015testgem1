require "spec_helper"

describe Meli::Order do
  before do
    @klass = Meli::Order
  end

  it "should options" do
    @klass.user_id= "158748360"

    expect(@klass.options).to eq({limit: 50,
                                  offset: 0,
                                  pages: -1,
                                  page:   0,
                                  kind:   [:recent, :archived],
                                  seller: "158748360" })
  end

  it "should options seller" do
    @klass.options = { seller: "158748360" }
    expect(@klass.options[:seller]).to eq("158748360")
  end

  it "should kind_path to recent" do
    expect(@klass.kind_path(:recent)).to eq('/orders/search/recent')
  end

  it "should kind_path to archived" do
    expect(@klass.kind_path(:archived)).to eq('/orders/search/archived')
  end


  it "should return user_id"

  it "should return order found"

  it "should return all orders"

  it "should return all_ids orders"

  it "should return find_every with block"
end
