module MongoMapperExt
  class File
    include MongoMapper::EmbeddedDocument

    key :_id, String
    key :name, String

    def put(filename, io, options = {})
      options[:_id] = grid_filename

      options[:metadata] ||= {}
      options[:metadata][:collection] = _root_document.collection.name

      self.name = filename
      if defined?(Magic)
        data = io.read(256) # be nice with memory usage
        options[:content_type] = Magic.guess_string_mime_type(data)
        io.rewind
      end

      gridfs.put(io, grid_filename, options)
    end

    def get
      gridfs.get(grid_filename)
    end

    def grid_filename
      @grid_filename ||= "#{_root_document.collection.name}/#{self.id}"
    end

    def mime_type
      get.content_type
    end

    def size
      get.file_length
    end

    def read(size = nil)
      self.get.read(size)
    end

    def delete
      gridfs.delete(grid_filename)
    end

    def method_missing(name, *args, &block)
      f = self.get rescue nil
      if f && f.respond_to?(name)
        f.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end

    protected
    def gridfs
      _root_document.class.gridfs
    end
  end
end
