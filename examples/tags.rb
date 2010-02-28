require './helper'

MongoMapperExt.init

class TagsEx
  include MongoMapper::Document
  include MongoMapperExt::Tags

  key :title
end

TagsEx.delete_all
TagsEx.create!(:title => "The title of the blogpost!!!", :tags => ["tag1", "tag2", "tag3"])
TagsEx.create!(:title => "testing tags", :tags => ["tag1", "tag4", "tag2"])
TagsEx.create!(:title => "more tags", :tags => ["tag1", "tag3", "tag5"])

puts ">> Tag Cloud"
puts TagsEx.tag_cloud.inspect

puts ">> with tag = tag5"
puts TagsEx.find_with_tags("tag5").inspect

puts ">> all tags that start with t"
puts TagsEx.find_tags(/^t/).inspect

TagsEx.delete_all