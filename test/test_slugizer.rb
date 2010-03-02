require 'helper'

class TestSlugizer < Test::Unit::TestCase
  context "working with slugs" do
    setup do
      BlogPost.delete_all
      @blogpost = BlogPost.create(:title => "%bLog pOSt tiTLe!",
                                  :body => "HeRe is tHe Body of the bLog pOsT")
    end

    should "generate the slug" do
      @blogpost.slug.should =~ /\w+-blog-post-title/
    end

    should "not generate the slug if the slug key is blank" do
      @empty_blogpost = BlogPost.new
      @empty_blogpost.slug.should be_nil
    end

    should "return the slug as param" do
      @blogpost.to_param =~ /\w+-blog-post-title/
    end

    should "return the id if slug was not generated" do
      @blogpost.slug = nil
      @blogpost.to_param.should == @blogpost.id
    end
  end

  context "finding objects" do
    setup do
      BlogPost.delete_all
      @blogpost = BlogPost.create(:title => "%bLog pOSt tiTLe!",
                                  :body => "HeRe is tHe Body of the bLog pOsT")
    end

    should "be able to find by slug" do
      BlogPost.by_slug(@blogpost.slug).should == @blogpost
    end

    should "be able to find by id" do
      BlogPost.by_slug(@blogpost.id).should == @blogpost
    end
  end
end
