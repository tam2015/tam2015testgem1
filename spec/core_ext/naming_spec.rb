describe CoreExt::Naming do
  before do
    class TestNaming
      extend ActiveModel::Naming
      include CoreExt::Naming
    end
  end

  it "should return model name and model_name" do
    new_model_name = ActiveModel::Name.new(TestNaming)

    expect(TestNaming.name      ).to eq("TestNaming")
    expect(TestNaming.model_name).to eq(new_model_name)
  end

  it "should set model name" do
    old_model_name  = TestNaming

    new_model_name  = old_model_name.clone
    new_model_name.name = "NewNaming"

    expect(old_model_name.name).to eq("TestNaming")
    expect(new_model_name.name).to eq("NewNaming")

    expect(new_model_name.name).to_not eq(old_model_name.name)
  end
end
