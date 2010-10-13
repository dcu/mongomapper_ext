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
      @blogpost.to_param.should == @blogpost.id.to_s
    end

    should "respect the max length option" do
      @blogpost = BlogPost.create(:title => "ultimo video/cancion en youtube?",
                                  :body => "HeRe is tHe Body of the bLog pOsT")
      @blogpost.slug.should =~ /\w+-ultimo-video-canci/
    end

    should "not accept slugs with length < :min_length" do
      @blogpost = BlogPost.create(:title => "a",
                                  :body => "HeRe is tHe Body of the bLog pOsT")
      @blogpost.slug.should be_nil
    end

    should "update the slug after updating the object" do
      @blogpost = BlogPost.create(:title => "ultimo video/cancion en youtube?",
                                  :body => "HeRe is tHe Body of the bLog pOsT")
      @blogpost.slug.should =~ /\w+-ultimo-video-canci/
      @blogpost.title = "primer video/cancion en youtube?"
      @blogpost.valid?
      @blogpost.slug.should =~ /\w+-primer-video-canci/
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
