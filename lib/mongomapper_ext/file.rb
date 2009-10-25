module MongoMapperExt
  class File < GridFS::GridStore
    attr_reader :id, :attributes

    def initialize(owner, attrs = {})
      @owner = owner
      @id = attrs.delete("_id")

      class_eval do
        attrs.each do |k,v|
          define_method(k) do
            v
          end
        end
      end

      super(@owner.class.database, attrs["filename"], "r", :root => @owner.collection.name)
    end

    def [](name)
      @attributes[name.to_s]
    end

    def self.fetch(owner, filename)
      db = owner.class.database
      criteria, options = MongoMapper::FinderOptions.new(owner.class, :filename => filename, :metadata => {:_id => owner.id}, :limit => 1).to_a

      obj = db.collection("#{owner.collection.name}.files").find(criteria, options).next_object

      if obj
        self.new(owner, obj)
      end
    end
  end
end
