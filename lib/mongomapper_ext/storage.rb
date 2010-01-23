module MongoMapperExt
  module Storage
    def self.included(model)
      model.class_eval do
        extend ClassMethods
        after_create :_sync_pending_files
      end
    end

    # FIXME: enable metadata. re http://jira.mongodb.org/browse/SERVER-377
    def put_file(filename, io, metadata = {})
      if !new?
        # :metadata => metadata.deep_merge({:_id => self.id})
        GridFS::GridStore.open(self.class.database, filename, "w",
                               :root => self.collection.name,
                               :metadata => {:_id => self.id}) do |f|
          while data = io.read(256)
            f.write(data)
          end
          io.close
        end
      else
        (@_pending_files ||= {})[filename] = io
      end
    end

    def fetch_file(filename)
      if !new?
        MongoMapperExt::File.fetch(self, filename)
      end
    end

    def files
      criteria, options = MongoMapper::FinderOptions.new(self.class, :metadata => {:_id => self.id}).to_a
      coll = self.class.database.collection("#{self.collection.name}.files")
      @files = coll.find(criteria, options).map do |a|
        MongoMapperExt::File.new(self, a)
      end
    end

    protected
    def _sync_pending_files
      if @_pending_files
        @_pending_files.each do |filename, data|
          put_file(filename, data)
        end
        @_pending_files = nil
      end
    end

    module ClassMethods
      def file_key(name)
        key "_#{name}", String
        define_method("#{name}=") do |file|
          file_id = UUIDTools::UUID.random_create.hexdigest
          filename = name

          if file.respond_to?(:original_filename)
            filename = file.original_filename
          elsif file.respond_to?(:path)
            filename = file.path
          end

          put_file(file_id, file, :original_filename => filename)
          self["_#{name}"] = file_id
        end

        define_method(name) do
          fetch_file(self["_#{name}"]) if metaclass.keys.has_key?("_#{name}")
        end
      end
    end
  end
end
