$:.unshift File.dirname(__FILE__)

require 'mongo/gridfs'
require 'mongo_mapper'
require 'uuidtools'

# types
require 'mongomapper_ext/types/open_struct'
require 'mongomapper_ext/types/timestamp'

# storage
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
