require './helper'

class StorageEx
  include MongoMapper::Document
  include MongoMapperExt::Storage

  file_key :my_file
end

file = StringIO.new("file content")
file2 = StringIO.new("file content 2")

s = StorageEx.new
s.put_file("filename.txt", file)
s.my_file = file2

s.save

from_db = StorageEx.find(s.id)

puts from_db.fetch_file("filename.txt").read
puts from_db.my_file.read
