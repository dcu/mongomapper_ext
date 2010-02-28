module MongoMapperExt
  module Tags
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods

        key :tags, Array, :index => true
      end
    end

    module ClassMethods
      def tag_cloud(conditions = {}, limit = 30)
        self.database.eval("function(collection, q,l) { return tag_cloud(collection, q,l); }", self.collection_name, conditions, limit)
      end

      # Model.find_with_tags("budget", "big", :limit => 4)
      def find_with_tags(*tags)
        options = tags.extract_options!
        self.all(options.merge(:tags => tags))
      end

      def find_tags(regex, conditions = {}, limit = 30)
        self.database.eval("function(collection, a,b,c) { return find_tags(collection, a,b,c); }", self.collection_name, regex, conditions, limit)
      end
    end
  end
end
