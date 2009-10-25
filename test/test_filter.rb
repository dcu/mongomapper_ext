require 'helper'

class TestFilter < Test::Unit::TestCase
  context "filtering data" do
    setup do
      BlogPost.delete_all
      @blogpost = BlogPost.create(:title => "%How dOEs tHIs Work?!",
                                  :body => "HeRe is tHe Body of the bLog pOsT",
                                  :tags => ["my", "list", "of", "tags"],
                                  :date => Time.parse('01-01-2009'))
    end

    should "be case insensitive" do
      BlogPost.filter("body").should == [@blogpost]
    end

    should "be able to find by title" do
      BlogPost.filter("this").should == [@blogpost]
    end

    should "be able to find by body" do
      BlogPost.filter("blog").should == [@blogpost]
    end

    should "be able to find by tags" do
      BlogPost.filter("list").should == [@blogpost]
    end

    should "be able to find by title or body" do
      BlogPost.filter("work blog").should == [@blogpost]
    end

    should "ignore inexistant words" do
      BlogPost.filter("work lalala").should == [@blogpost]
    end

    should "allow to paginate results" do
      results = BlogPost.filter("tag", :per_page => 1, :page => 1)
      results.should == [@blogpost]
      results.total_pages.should == 1
    end
  end
end
