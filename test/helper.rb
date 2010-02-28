require 'rubygems'

gem 'jnunemaker-matchy'

require 'matchy'
require 'shoulda'
require 'timecop'
require 'mocha'
require 'pp'

require 'support/custom_matchers'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mongomapper_ext'
MongoMapper.database = 'test'

require 'models'

class Test::Unit::TestCase
  include CustomMatchers
end

MongoMapperExt.init
