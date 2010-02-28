require 'helper'

class TestTags < Test::Unit::TestCase
  context "working with tags" do
    setup do
      BlogPost.delete_all
      @blogpost = BlogPost.create(:title => "operation systems",
                                  :body => "list of some operating systems",
                                  :tags => %w[list windows freebsd osx linux])
      @blogpost2 = BlogPost.create(:title => "nosql database",
                                   :body => "list of some nosql databases",
                                   :tags => %w[list mongodb redis couchdb])
    end

    should "generate the tagcloud" do
      cloud = BlogPost.tag_cloud

      [{"name"=>"list", "count"=>2.0},
       {"name"=>"windows", "count"=>1.0},
       {"name"=>"freebsd", "count"=>1.0},
       {"name"=>"osx", "count"=>1.0},
       {"name"=>"linux", "count"=>1.0},
       {"name"=>"mongodb", "count"=>1.0},
       {"name"=>"redis", "count"=>1.0},
       {"name"=>"couchdb", "count"=>1.0}].each do |entry|
        cloud.should include(entry)
      end
    end

    should "find blogpost that include the given tags" do
      BlogPost.find_with_tags("mongodb").should == [@blogpost2]
      posts = BlogPost.find_with_tags("mongodb", "linux")
      posts.should include(@blogpost)
      posts.should include(@blogpost2)
      posts.size.should == 2
    end

    should "find tags that start with li" do
      tags = BlogPost.find_tags(/^li/)
      tags.should include("linux")
      tags.should include("list")
      tags.size.should == 2
    end

  end
end
