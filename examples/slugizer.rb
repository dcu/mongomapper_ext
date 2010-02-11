require './helper'

class SlugizerEx
  include MongoMapper::Document
  include MongoMapperExt::Slugizer

  slug_key :title, :unique => true

  key :title
end

u = SlugizerEx.create(:title => "The title of the blogpost!!!")

puts u.slug
puts SlugizerEx.by_slug(u.slug).inspect

