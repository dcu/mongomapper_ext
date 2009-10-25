require 'helper'

class TimestampTest < Test::Unit::TestCase
  def from_db
    Event.find(@event.id)
  end

  context "working with timestamps" do
    setup do
      Event.delete_all

      Time.zone = 'UTC'
      @start_time = Time.zone.parse('01-01-2009')
      @end_time = @start_time.tomorrow

      @event = Event.create!(:start_date => @start_time, :end_date => @end_time)
    end

    should "store the date" do
      from_db.start_date.to_s.should == @start_time.to_s
    end

    should "be able to convert the time to the given timezone" do
      Time.zone = 'Hawaii'
      from_db.start_date.to_s.should == "2008-12-31 14:00:00 -1000"
    end

    should "be able to compare dates" do
      start_time = @start_time.tomorrow.tomorrow
      end_time = start_time.tomorrow

      @event2 = Event.create!(:start_date => start_time, :end_datime => end_time)

      Event.count.should == 2
      events = Event.find(:all, :$where => ("this.start_date >= %d && this.start_date <= %d" % [@event.start_date.yesterday.to_i, @event2.start_date.yesterday.to_i]))

      events.should == [@event]
    end
  end
end
