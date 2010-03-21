module MongoMapperExt
  module Storage
    def self.included(model)
      model.class_eval do
        extend ClassMethods

        file_list :file_list
      end
    end

    def put_file(name, io, options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.put(name, io, options)
    end

    def fetch_file(name, options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.get(name)
    end

    def files(options = {})
      file_list = send(options.delete(:in) || :file_list)
      file_list.files
    end

    module ClassMethods
      def gridfs
        @gridfs ||= Mongo::Grid.new(self.database)
      end

      def file_list(name)
        key name, MongoMapperExt::FileList
        define_method(name) do
          list = self[name]
          list.parent_document = self
          list
        end

        after_create do |doc|
          doc.send(name).sync_files
          doc.save(:validate => false)
        end

        before_destroy do |doc|
          doc.send(name).destroy_files
        end
      end

      def file_key(name, opts = {})
        opts[:in] ||= :file_list

        define_method("#{name}=") do |file|
          send(opts[:in]).get(name).put(name, file)
        end

        define_method(name) do
          send(opts[:in]).get(name)
        end

        define_method("has_#{name}?") do
          send(opts[:in]).has_key?(name)
        end
      end

      private
    end
  end
end
