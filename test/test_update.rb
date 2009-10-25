require 'helper'

class UpdateTest < Test::Unit::TestCase
  should "only update the given white listed attributes" do
    event = Event.new(:password => "original")
    start_date = Time.zone.now
    end_date = start_date.tomorrow

    event.safe_update(%w[start_date end_date], {"start_date" => start_date,
                                                "end_date" => end_date,
                                                "password" => "hacked"})
    event.password.should == "original"
    event.start_date.to_s.should == start_date.to_s
    event.end_date.to_s.should == end_date.to_s
  end
end
