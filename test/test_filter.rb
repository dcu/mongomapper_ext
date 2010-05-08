require 'helper'

class TestFilter < Test::Unit::TestCase
  context "filtering data" do
    setup do
      BlogPost.delete_all
      @blogpost = BlogPost.create!(:title => "%How dOEs tHIs Work?!",
                                   :body => "HeRe is tHe Body of the bLog pOsT",
                                   :tags => ["my", "list", "of", "tags"])
      @entradablog = BlogPost.create!(:title => "sobre las piña",
                                      :body => "la piña no es un árbol",
                                      :tags => ["frutas"])
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

    should "normalize the text" do
      BlogPost.filter("pina").should == [@entradablog]
      BlogPost.filter("arbol").should == [@entradablog]
    end

    should "allow to paginate results" do
      results = BlogPost.filter("tag", :per_page => 1, :page => 1)
      results.should == [@blogpost]
      results.total_pages.should == 1
    end
  end
end
