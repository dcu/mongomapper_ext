require 'helper'

class StorageTest < Test::Unit::TestCase
  context "Storing files" do
    setup do
      @avatar = Avatar.create
      @data = StringIO.new("my avatar image")
    end

    should "store the file" do
      @avatar.put_file("an_avatar.png", @data)
      data = Avatar.find(@avatar.id).fetch_file("an_avatar.png").read
      data.should == "my avatar image"
    end

    should "close the file after storing" do
      @avatar.put_file("an_avatar.png", @data)
      @data.should be_closed
    end

    context "in attributes" do
      should "store the given file" do
        @avatar.data = @data
        @avatar.save!
        @avatar.data.should_not be_nil
        @avatar.data.read.should == "my avatar image"
      end
    end

    context "with new objects" do
      setup do
        @avatar = Avatar.new
      end

      should "store the file after saving" do
        @avatar.put_file("an_avatar.png", @data)
        @avatar.save
        @avatar.fetch_file("an_avatar.png").read.should == "my avatar image"
      end

      should "store not the file if object is new" do
        @avatar.put_file("an_avatar.png", @data)
        @avatar.fetch_file("an_avatar.png").should be_nil
      end
    end
  end

  context "Fetching files" do
    setup do
      @avatar = Avatar.create
      @data = StringIO.new("my avatar image")
    end

    should "fetch the list of files" do
      @avatar.put_file("file1", StringIO.new("data1"))
      @avatar.put_file("file2", StringIO.new("data2"))
      @avatar.put_file("file3", StringIO.new("data3"))
      file_names = @avatar.files.map { |f| f.filename }
      file_names.should include("file1")
      file_names.should include("file2")
      file_names.should include("file3")
    end
  end
end
