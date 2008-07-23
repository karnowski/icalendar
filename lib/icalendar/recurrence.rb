require 'rubygems'
require 'runt'
include Runt

module Icalendar
  class RecurrenceRule
    #currently unused, but here for spec compliance
    attr_accessor :rrulparam

    #required
    attr_accessor :freq

    #only one of these two optional may occur
    attr_accessor :until
    attr_accessor :count

    #optional values    
    attr_accessor :interval
    attr_accessor :bysecond
    attr_accessor :byminute
    attr_accessor :byhour
    attr_accessor :byday
    attr_accessor :bymonthday
    attr_accessor :byyearday
    attr_accessor :byweekno
    attr_accessor :bymonth
    attr_accessor :bysetpos
    attr_accessor :wkst

    def initialize(rrule)
      for part in rrule.split(";")
        key, value = part.split("=")
	      key.downcase!
        if self.methods.include?(key)
          self.send(key + "=", value)
        end
      end
    end

    def to_s
      items = []
      
      if @freq
        items << "FREQ=#@freq"
      end

      if @until
        items << "UNTIL=#@until"
      end

      if @count
        items << "COUNT=#@count"
      end

      if @interval
        items << "INTERVAL=#@interval"
      end

      if @bysecond
        items << "BYSECOND=#@bysecond"
      end

      if @byminute
        items << "BYMINUTE=#@byminute"
      end

      if @byhour
        items << "BYHOUR=#@byhour"
      end

      if @byday
        items << "BYDAY=#@byday"
      end

      if @bymonthday
        items << "BYMONTHDAY=#@bymonthday"
      end

      if @byyearday
        items << "BYYEARDAY=#@byyearday"
      end

      if @byweekno
        items << "BYWEEKNO=#@byweekno"
      end

      if @bymonth
        items << "BYMONTH=#@bymonth"
      end

      if @bysetpos
        items << "BYSETPOS=#@bysetpos"
      end

      if @wkst
        items << "WKST=#@wkst"
      end

      items.join(";")
    end

    #maps the byday values from the spec to a useful runt constant;
    #LJK: I'm guessing these change when WKST=MO?
    BYDAY_MAP = {
      "SU" => 0,
      "MO" => 1,
      "TU" => 2,
      "WE" => 3,
      "TH" => 4,
      "FR" => 5,
      "SA" => 6,
    }

    def get_recurrence_set(start_date_time, end_date_time)
      if @freq == "DAILY"
        start_date_time.date_precision = DPrecision::DAY
        temporal_exp = REWeek.new(Sun, Sat)
      elsif @freq == "WEEKLY"
        start_date_time.date_precision = DPrecision::DAY
        
        if @byday
          #convert each day string into a DIWeek expression and then "or" them together          
          day_strings = @byday.split(",")
          runt_exps = day_strings.collect {|day| DIWeek.new(BYDAY_MAP[day]) }
          temporal_exp = runt_exps.inject {|exp, n| exp | n }
        else
          temporal_exp = DIWeek.new(start_date_time.wday)
        end
      elsif @freq == "YEARLY"
        start_date_time.date_precision = DPrecision::YEAR
        temporal_exp = REYear.new(start_date_time.mon, start_date_time.mday)
      end
      
      if @interval
        puts "precision = " + start_date_time.date_precision.to_s
        temporal_exp &= EveryTE.new(start_date_time, @interval.to_i)
      end
      
      if @bymonth
        #convert each day string into a REYear expression and then "or" them together          
        month_strings = @bymonth.split(",")
        runt_exps = month_strings.collect {|month| exp = REYear.new(month.to_i) }
        temporal_exp &= runt_exps.inject {|exp, n| exp | n }
      end
      
      if @until
        end_date_time = DateTime.parse(@until)
      end
      
      puts "temporal_exp = " + temporal_exp.to_s
      dates = temporal_exp.dates(DateRange.new(start_date_time, end_date_time))
      
      if @count
        return dates[0,@count.to_i]
      else
        return dates
      end
    end
    
    #convenience method for creating an array of dates, one per day, from a start to an end date
    def self.get_date_range(start_date, end_date)
      dates = []
      start_date.upto(end_date) {|date| dates << date}
      dates
    end    

  end
end
