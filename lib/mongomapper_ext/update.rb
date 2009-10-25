module MongoMapperExt
  module Update
    def safe_update(white_list, values)
      white_list.each do |key|
        send("#{key}=", values[key]) if values.has_key?(key)
      end
    end
  end
end
MongoMapper::EmbeddedDocument.send(:include, MongoMapperExt::Update)
