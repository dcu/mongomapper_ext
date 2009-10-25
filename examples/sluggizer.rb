require './helper'

class SluggizerEx
  include MongoMapper::Document
  include MongoMapperExt::Sluggizer

  slug_key :title

  key :title
end

u = SluggizerEx.create(:title => "The title of the blogpost!!!")

puts u.slug
puts SluggizerEx.by_slug(u.slug).inspect