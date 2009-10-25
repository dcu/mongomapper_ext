require './helper'

class UpdateEx
  include MongoMapper::Document

  key :a
  key :b
  key :c
end

u = UpdateEx.create(:a => 1, :b => 0, :c => 1)

u.safe_update(%w[a c], {"a" => 3, "b" => 3, "c" => 3})
puts u.attributes.inspect
