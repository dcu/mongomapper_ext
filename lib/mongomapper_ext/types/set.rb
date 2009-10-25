class Set
  def self.to_mongo(value)
    value.to_a
  end

  def self.from_mongo(value)
    Set.new(value)
  end
end
