class Timestamp
  def self.from_mongo(value)
    if value.nil? || value == ''
      nil
    else
      Time.zone.at(value.to_i)
    end
  end

  def self.to_mongo(value)
    value.to_i
  end
end

Time.zone ||= 'UTC'
