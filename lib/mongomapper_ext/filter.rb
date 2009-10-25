module MongoMapperExt
  module Filter
    def self.included(klass)
      require 'lingua/stemmer'

      klass.class_eval do
        extend ClassMethods

        key :_keywords, Array
        ensure_index :_keywords

        before_save :_update_keywords
      end
    end

    module ClassMethods
      def filterable_keys(*keys)
        @filterable_keys ||= Set.new
        @filterable_keys += keys

        @filterable_keys
      end

      def language(lang = 'en')
        @language ||= lang
      end

      def filter(query, opts = {})
        q = query.downcase.split.map do |k|
          Regexp.escape(k)
        end.join("|")
        if opts[:per_page]
          self.paginate(opts.deep_merge(:conditions => {:_keywords => /^(#{q}).*/ }))
        else
          self.find(:all, opts.deep_merge(:conditions => {:_keywords => /^(#{q}).*/ }))
        end
      end
    end

    protected
    def _update_keywords
      lang = self.class.language
      if lang.kind_of?(Symbol)
        lang = send(lang)
      elsif lang.kind_of?(Proc)
        lang = lang.call(self)
      end

      s = Lingua::Stemmer.new(:language => lang)

      self._keywords = []
      self.class.filterable_keys.each do |key|
        self._keywords += keywords_for_value(s, read_attribute(key))
      end
    end

    private
    def keywords_for_value(stemmer, val)
      if val.kind_of?(String)
        val.downcase.split.map do |word|
          stem = stemmer.stem(word)
          if stem != word
            [stem, word]
          else
            word
          end
        end.flatten
      elsif val.kind_of?(Array)
        val.map { |e| keywords_for_value(stemmer, e) }.flatten
      else
        [val]
      end
    end
  end
end

