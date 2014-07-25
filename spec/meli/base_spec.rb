require "spec_helper"

describe Meli::Base do
  it "should set include_site_id " do
    expect(Meli::Base.include_site_id).to be false

    Meli::Base.include_site_id = true

    expect(Meli::Base.include_site_id).to be
  end

  it "collection_path with include_site_id" do
    Meli::Base.include_site_id = true

    expect(Meli::Base.collection_path).to eq("/sites/MLB/bases")
  end
end
