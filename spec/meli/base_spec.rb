# encoding: UTF-8

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

  it "should attribute name" do
    item_with_name    = @klass.new({ name: "Data Name" })
    item_without_name = @klass.new({ data: "Data Name" })

    expect(   item_with_name.name).to eql("Data Name")
    expect(item_without_name.name).to eql("Meli::Another")
  end

  it "attribute changes" do
    item_with_name    = @klass.new({ name: "Name" })

    expect(item_with_name.changes).to eq({})

    item_with_name.name = "Full Name"

    expect(item_with_name.changes).to eq({ "name" => ["Name", "Full Name"] })
  end
end
