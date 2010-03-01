module MongoMapperExt
  module Slugizer
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        extend Finder

        key :slug, String, :index => true

				before_validation :generate_slug
      end
    end

    def to_param
      self.slug.blank? ? self.id : self.slug
    end

    protected

    def generate_slug
			slug = self[self.class.slug_key].parameterize.to_s
      if !self.class.slug_options[:unique]
        key = UUIDTools::UUID.random_create.hexdigest[0,4] #optimize
        self.slug = key+"-"+slug
      else
        self.slug = slug
      end
    end

    module ClassMethods
      def slug_key(key = :name, options = {})
        @slug_options ||= options
        @slug_key ||= key
      end
      class_eval do
        attr_reader :slug_options
      end
    end

    module Finder
      def by_slug(id, options = {})
        self.find_by_slug(id, options) || self.first(options.merge({:_id => id}))
      end
      alias :find_by_slug_or_id :by_slug
    end
  end
end

if defined?(MongoMapper::Associations)
  MongoMapper::Associations::Proxy.send(:include, MongoMapperExt::Slugizer::Finder)
else
  MongoMapper::Plugins::Associations::Proxy.send(:include, MongoMapperExt::Slugizer::Finder)
end
