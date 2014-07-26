describe ToSnakeKeys do
  before do
    @item         = { "id"=>"MLB98647", "totalItemInThisCategory"      =>28, "name"=>['1ª e 2ª Geração", "3ª Geração'], "subItems" =>[] }
    @snaked_item  = { "id"=>"MLB98647", "total_item_in_this_category"  =>28, "name"=>['1ª e 2ª Geração", "3ª Geração'], "sub_items"=>[] }

    @hash   = @item.merge       ({ "subItems" =>[@item, @item] })
    @snaked = @snaked_item.merge({ "sub_items"=>[@snaked_item, @snaked_item] })
  end

  it "should return hash with array" do
    expect(@item.underscore).to eq(@snaked_item)
  end

  it "should return array with hash" do
    expect([@item, @item].underscore).to eq([@snaked_item, @snaked_item])
  end

  it "should return hash with array with hash" do
    expect(@hash.underscore).to eq(@snaked)
  end
end
