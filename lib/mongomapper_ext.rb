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
