require './helper'
require 'mongomapper_ext/types/translation'

class TranslationEx
  include MongoMapper::Document

  key :title, Translation, :default => Translation.build({"es" => "titulo", "en" => "title"}, "en")
  key :body, Translation, :default => Translation.build({"es" => "contenido", "en" => "content"}, "en")
end

TranslationEx.delete_all
o1 = TranslationEx.create
o2 = TranslationEx.create


o1.title = "my new title"
puts o1.title[:es]

o1.title[:es] = "mi nuevo titulo"
o1.save

puts "languages: #{o1.title.languages.inspect}"
puts "default text: #{o1.title}"

o1 = TranslationEx.find(o1.id)
o2 = TranslationEx.find(o2.id)

puts o1.to_mongo.inspect


TranslationEx.delete_all

