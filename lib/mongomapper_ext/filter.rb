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

        key :_keywords, Set
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

      stop_words = []
      if self.respond_to?("#{lang}_stop_words")
        stop_words = Set.new(self.send("#{lang}_stop_words"))
      end

      self._keywords = []
      self.class.filterable_keys.each do |key|
        self._keywords += keywords_for_value(read_attribute(key), stemmer, stop_words)
      end
    end

    private
    def keywords_for_value(val, stemmer=nil, stop_words = [])
      if val.kind_of?(String)
        words = []
        val.downcase.split.each do |word|
          next if word.length < 3
          next if word =~ %r{'|"|\/|\\}
          next if stop_words.include?(word)

          stem = word
          if stemmer
            stem = stemmer.stem(word)
          end

          if stem && stem != word
            words += [stem, word]
          else
            words << word
          end
        end

        words
      elsif val.kind_of?(Array)
        val.map { |e| keywords_for_value(e, stemmer, stop_words) }.flatten
      elsif val
        [val]
      else
        []
      end
    end

    def en_stop_words
      ["a", "about", "above", "after", "again", "against", "all", "am", "an",
       "and", "any", "are", "aren't", "as", "at", "be", "because", "been",
       "before", "being", "below", "between", "both", "but", "by", "cannot",
       "can't", "could", "couldn't", "did", "didn't", "do", "does", "doesn't",
       "doing", "don't", "down", "during", "each", "few", "for", "from",
       "further", "had", "hadn't", "has", "hasn't", "have", "haven't", "having",
       "he", "he'd", "he'll", "her", "here", "here's", "hers", "herself", "he's",
       "him", "himself", "his", "how", "how's", "i", "i'd", "if", "i'll", "i'm",
       "in", "into", "is", "isn't", "it", "its", "it's", "itself", "i've", "let's",
       "me", "more", "most", "mustn't", "my", "myself", "no", "nor", "not", "of",
       "off", "on", "once", "only", "or", "other", "ought", "our", "ours", "ourselves",
       "out", "over", "own", "same", "shan't", "she", "she'd", "she'll", "she's",
       "should", "shouldn't", "so", "some", "such", "than", "that", "that's", "the",
       "their", "theirs", "them", "themselves", "then", "there", "there's", "these",
       "they", "they'd", "they'll", "they're", "they've", "this", "those", "through",
       "to", "too", "under", "until", "up", "very", "was", "wasn't", "we", "we'd",
       "we'll", "were", "we're", "weren't", "we've", "what", "what's", "when",
       "when's", "where", "where's",  "which", "while", "who", "whom", "who's",
       "why", "why's", "with", "won't", "would", "wouldn't", "you", "you'd",
       "you'll", "your", "you're", "yours", "yourself", "yourselves", "you've",
       "the", "how"]
    end

    def es_stop_words
      ["de", "la", "que", "el", "en", "y", "a",
       "los", "del", "se", "las", "por", "un", "para", "con", "no", "una", "su",
       "al", "lo", "como", "mas", "pero", "sus", "le", "ya", "o", "este", "sus",
       "si", "porque", "esta", "entre",
       "cuando", "muy", "sin", "sobre", "tambien", "me", "hasta", "hay",
       "donde", "quien", "desde", "todo", "nos", "durante", "todos", "uno", "les",
       "ni", "contra", "otros", "ese", "eso", "ante", "ellos", "e", "esto",
       "mi", "antes", "algunos", "que", "unos", "yo", "otro",
       "otras", "otra", "al", "tanto", "esa", "estos", "mucho", "quienes",
       "nada", "muchos", "cual", "poco", "ella", "estar", "estas", "algunas",
       "algo", "nosotros", "mi", "mis", "tus", "ellas", "sus", "una", "uno",
       "nosotras", "vosostros", "vosostras", "os", "mio", "mia",
       "mios", "mias", "tuyo", "tuya", "tuyos", "tuyas", "suyo",
       "suya", "suyos", "suyas", "nuestro", "nuestra", "nuestros", "nuestras",
       "vuestro", "vuestra", "vuestros", "vuestras", "esos", "esas", "estoy",
       "estas", "esta", "estamos", "estais", "estan",
       "este", "estes", "estemos", "esteis", "esten",
       "estare", "estareis", "estara", "estaremos", "como",
       "estareis", "estarin", "estaria", "estarias",
       "estariamos", "estariais", "estarian", "estaba",
       "estabas", "estabamos", "estabais", "estaban", "estuve",
       "estuviste", "estuvo", "estuvimos", "estuvisteis", "estuvieron", "estuviera",
       "estuvieras", "estuvieramos", "estuvierais", "estuvieran", "estuviese",
       "estuvieses", "estuviesemos", "estuvieseis", "estuviesen", "estando",
       "estado", "estada", "estados", "estadas", "estad", "he", "has", "ha", "hemos",
       "habeis", "han", "haya", "hayas", "hayamos", "hayais", "hayan",
       "habre", "habras", "habra", "habremos", "habreis",
       "habran", "habria", "habrias", "habriamos",
       "habriais", "habrian", "habia", "habias",
       "habiamos", "habiais", "habian", "hube", "hubiste",
       "hubo", "hubimos", "hubisteis", "hubieron", "hubiera", "hubieras", "hubieramos",
       "hubierais", "hubieran", "hubiese", "hubieses", "hubiesemos", "hubieseis",
       "hubiesen", "habiendo", "habido", "habida", "habidos", "habidas", "soy", "eres",
       "es", "somos", "sois", "son", "sea", "seas", "seamos", "seais",
       "sean", "sere", "seras", "sera", "seremos", "sereis",
       "seran", "seria", "serias", "seriamos", "seriais",
       "serian", "era", "eras", "eramos", "erais", "eran", "fui",
       "fuiste", "fue", "fuimos", "fuisteis", "fueron", "fuera", "fueras",
       "fueramos", "fuerais", "fueran", "fuese", "fueses", "fuesemos",
       "fueseis", "fuesen", "sintiendo", "sentido", "sentida", "sentidos", "sentidas",
       "siente", "sentid", "tengo", "tienes", "tiene", "tenemos", "teneis",
       "tienen", "tenga", "tengas", "tengamos", "tengais", "tengan", "tendre",
       "tendras", "tendra", "tendremos", "tendreis", "tendran",
       "tendria", "tendrias", "tendriamos", "tendriais",
       "tendrian", "tenia", "tenias", "teniamos",
       "teniais", "tenian", "tuve", "tuviste", "tuvo", "tuvimos",
       "tuvisteis", "tuvieron", "tuviera", "tuvieras", "tuvieramos",
       "tuvierais", "tuvieran", "tuviese", "tuvieses", "tuviesemos",
       "tuvieseis", "tuviesen", "teniendo", "tenido", "tenida", "tenidos", "tenidas", "tened"]
    end
  end
end

