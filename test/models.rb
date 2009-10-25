
class Event
  include MongoMapper::Document

  key :start_date, Timestamp
  key :end_date, Timestamp

  key :password, String
end


class Recipe
  include MongoMapper::Document

  key :ingredients, Set
end

class Avatar
  include MongoMapper::Document
  include MongoMapperExt::Storage

  file_key :data
end


class BlogPost
  include MongoMapper::Document
  include MongoMapperExt::Filter

  filterable_keys :title, :body

  key :title, String
  key :body, String
end
