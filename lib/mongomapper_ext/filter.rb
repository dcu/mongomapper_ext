module MongoMapperExt
  module Filter
    def self.included(klass)
      begin
        require 'lingua/stemmer'
      rescue LoadError
        $stderr.puts "install ruby-stemmer `gem install ruby-stemmer` to activate the full text search support"
      end

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
          self.all(opts.deep_merge(:conditions => {:_keywords => /^(#{q}).*/ }))
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

      stemmer = nil
      if defined?(Lingua)
        stemmer = Lingua::Stemmer.new(:language => lang)
      end

      self._keywords = []
      self.class.filterable_keys.each do |key|
        self._keywords += keywords_for_value(read_attribute(key), stemmer)
      end
    end

    private
    def keywords_for_value(val, stemmer=nil)
      if val.kind_of?(String)
        val.downcase.split.map do |word|
          stem = word
          if stemmer
            stem = stemmer.stem(word)
          end

          if stem != word
            [stem, word]
          else
            word
          end
        end.flatten
      elsif val.kind_of?(Array)
        val.map { |e| keywords_for_value(e, stemmer) }.flatten
      else
        [val]
      end
    end
  end
end

