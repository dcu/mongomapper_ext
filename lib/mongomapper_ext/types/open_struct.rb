require 'ostruct'

class OpenStruct
  def self.to_mongo(value)
    if value.kind_of?(self)
      value.send(:table)
    else
      value
    end
  end

  def self.from_mongo(value)
    OpenStruct.new(value || {})
  end
end
