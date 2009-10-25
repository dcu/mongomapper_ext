require './helper'

class TypeEx
  include MongoMapper::Document

  key :time, Timestamp
  key :config, OpenStruct
  key :set, Set
end


type = TypeEx.new(:set => Set.new, :config => OpenStruct.new)

type.config.name = "Alan"
type.config.last_name = "Turing"


type.time = Time.now
type.set += [1,1,2,3,2,2]

type.save

from_db = TypeEx.find(type.id)

puts from_db.config.inspect
puts from_db.set.inspect

Time.zone = "Hawaii"
puts from_db.time.inspect

from_db.destroy

