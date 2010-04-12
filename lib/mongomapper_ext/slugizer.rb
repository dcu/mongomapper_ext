module MongoMapperExt
  module Slugizer
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        extend Finder

        key :slug, String, :index => true
      end
    end

    def to_param
      self.slug.blank? ? self.id : self.slug
    end

    protected

    def generate_slug
      return false if self[self.class.slug_key].blank?
      max_length = self.class.slug_options[:max_length]
      min_length = self.class.slug_options[:min_length] || 0

      slug = self[self.class.slug_key].parameterize.to_s
      slug = slug[0, max_length] if max_length

      if slug.size < min_length
        slug = nil
      end

      if slug && !self.class.slug_options[:unique]
        key = UUIDTools::UUID.random_create.hexdigest[0,4] #optimize
        self.slug = key+"-"+slug
      else
        self.slug = slug
      end
    end

    module ClassMethods
      def slug_key(key = :name, options = {})
        @slug_options ||= options
        @callback_type ||= begin
          type = options[:callback_type] || :before_validation_on_create

          send(type, :generate_slug)

          type
        end

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
