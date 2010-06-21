$:.unshift File.dirname(__FILE__)

if RUBY_VERSION =~ /^1\.8/
  $KCODE = 'u'
end

require 'mongo_mapper'
require 'uuidtools'
require 'active_support/inflector'

begin
  require 'magic'
rescue LoadError
  $stderr.puts "disabling `magic` support. use 'gem install magic' to enable it"
end

require 'mongomapper_ext/paginator'

# types
require 'mongomapper_ext/types/open_struct'
require 'mongomapper_ext/types/timestamp'
require 'mongomapper_ext/types/translation'

# storage
require 'mongomapper_ext/file_list'
require 'mongomapper_ext/file'
require 'mongomapper_ext/storage'

# update
require 'mongomapper_ext/update'

# filter
require 'mongomapper_ext/filter'

# slug
require 'mongomapper_ext/slugizer'

# tags
require 'mongomapper_ext/tags'

module MongoMapperExt
  def self.init
    load_jsfiles(::File.dirname(__FILE__)+"/mongomapper_ext/js")
  end

  def self.load_jsfiles(path)
    Dir.glob(::File.join(path, "*.js")) do |js_path|
      code = ::File.read(js_path)
      name = ::File.basename(js_path, ".js")

      # HACK: looks like ruby driver doesn't support this
      MongoMapper.database.eval("db.system.js.save({_id: '#{name}', value: #{code}})")
    end
  end
end

