require './helper'

class FilterEx
  include MongoMapper::Document
  include MongoMapperExt::Filter

  key :title, String
  key :body, String

  filterable_keys :title, :body
end

FilterEx.delete_all
o1 = FilterEx.create(:title => "A Great Title", :body => "A great Body")
o2 = FilterEx.create(:title => "A Good Title", :body => "A good Body")


puts "filter: #{FilterEx.filter("title").size}"
puts "filter: #{FilterEx.filter("title", :limit => 1).inspect}"
puts "filter: #{FilterEx.filter("great").inspect}"


FilterEx.delete_all