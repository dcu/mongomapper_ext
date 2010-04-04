
class Event # for safe_update, and Timestamp
  include MongoMapper::Document

  key :start_date, Timestamp
  key :end_date, Timestamp

  key :password, String
end

class Recipe # for Set
  include MongoMapper::Document
  include MongoMapperExt::Filter

  language Proc.new { |d| d.language }
  filterable_keys :language

  key :ingredients, Set
  key :description, String
  key :language, String, :default => 'en'
end

class Avatar # for Storage and File
  include MongoMapper::Document
  include MongoMapperExt::Storage

  file_key :data

  file_list :alternatives
  file_key :first_alternative, :in => :alternatives
end

class UserConfig #for OpenStruct
  include MongoMapper::Document
  key :entries, OpenStruct
end

class BlogPost # for Slug and Filter
  include MongoMapper::Document
  include MongoMapperExt::Filter
  include MongoMapperExt::Slugizer
  include MongoMapperExt::Tags

  filterable_keys :title, :body, :tags, :date
  slug_key :title, :max_length => 18, :min_length => 3, :callback_type => :before_validation
  language :find_language

  key :title, String
  key :body, String
  key :tags, Array
  key :date, Time

  def find_language
    'en'
  end
end
