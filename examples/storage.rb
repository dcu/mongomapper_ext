require './helper'

class StorageEx
  include MongoMapper::Document
  include MongoMapperExt::Storage

  file_key :default_file

  file_list :attachments
  file_key :an_attachment, :in => :attachments
end

default_file = StringIO.new("default file content")
custom_attachment = StringIO.new("custom attachment content")

attachment = File.open(__FILE__)

StorageEx.destroy_all

s = StorageEx.new

s.default_file = default_file
s.attachments.put("custom_attachment.txt", custom_attachment)
s.an_attachment = attachment

s.save


from_db = StorageEx.find(s.id)

puts "READ DEFAULT FILE"
puts from_db.default_file.read

puts "READ CUSTOM ATTACHMENT"
puts from_db.attachments.get("custom_attachment.txt").read

puts "READ NAMED ATTACHMENT"
puts from_db.an_attachment.read.inspect
puts "MIME TYPE: #{from_db.an_attachment.mime_type}"
