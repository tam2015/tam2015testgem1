require "spec_helper"

describe Meli::Base do
  before do
    @klass = Meli::Another = Class.new Meli::Base
    @klass.include_site_id = true
  end

  it "include_site_id must define in another class without affecting the base" do
    expect(@klass.include_site_id).to be
    expect(Meli::Base.include_site_id).to be false
  end

  it "collection_path with include_site_id" do
    expect(@klass.collection_path).to eq("/sites/MLB/anothers")
  end
end
