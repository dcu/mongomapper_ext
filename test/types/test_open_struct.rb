require 'helper'

class OpenStructTest < Test::Unit::TestCase
  def from_db
    UserConfig.find(@config.id)
  end

  context "working with sets" do
    setup do
      @config = UserConfig.create!(:entries => OpenStruct.new({}))
    end

    should "allow to add new keys" do
      @config.entries.new_key = "my new key"
      @config.save!
      from_db.entries.new_key.should == "my new key"
    end
  end
end
