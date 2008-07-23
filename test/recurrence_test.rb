$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'icalendar'

require 'set'
require 'date'


class TestRecurrences < Test::Unit::TestCase
  include Icalendar

  END_DATE = DateTime.new(2002,1,1,0,00)

  #these rules are included in all of Google Calendars' iCal exports
  #LJK: improve this test!
  def test_parse_daylight_savings_time_rules
    starts = RecurrenceRule.new("FREQ=YEARLY;BYMONTH=4;BYDAY=1SU")
    ends   = RecurrenceRule.new("FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU")

    assert_equal(starts.freq, "YEARLY")
    assert_equal(starts.bymonth, "4")
    assert_equal(starts.byday, "1SU")

    assert_equal(ends.freq, "YEARLY")
    assert_equal(ends.bymonth, "10")
    assert_equal(ends.byday, "-1SU")
  end

  # "Daily for 10 occurences"
  def test_rfc_2445_example_1
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=DAILY;COUNT=10")
    
    expected = RecurrenceRule.get_date_range(dstart, DateTime.parse("US-Eastern:19970911T090000"))
    results = rrule.get_recurrence_set(dstart, END_DATE)
    
    assert_equal(expected, results)
  end

  # "Daily until December 24, 1997"
  def test_rfc_2445_example_2
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=DAILY;UNTIL=19971224T000000Z")
    
    expected = RecurrenceRule.get_date_range(dstart, DateTime.parse("US-Eastern:19971223T090000"))
    results = rrule.get_recurrence_set(dstart, DateTime.new(2000,1,1,0,0))
    
    assert_equal(expected, results)
  end
  
=begin  
  # "Every other day - forever"
  def test_rfc_2445_example_3
  end
=end


  # "Every 10 days, 5 occurrences"
  def test_rfc_2445_example_4
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=DAILY;INTERVAL=10;COUNT=5")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970912T090000"), #Sep 12
      DateTime.parse("US-Eastern:19970922T090000"), #Sep 22
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
      DateTime.parse("US-Eastern:19971012T090000"), #Oct 12
    ]
    
    #LJK: note this takes a LONG time to run with the normal END_DATE
    results = rrule.get_recurrence_set(dstart, DateTime.parse("US-Eastern:19980301T090000"))
    
    assert_equal(expected, results)    
  end


  # "Every 10 days, until Oct 12"
  # there is no example in the spec to test the daily interval with until,
  # so I'm adapting example 4 to use an until clause
 def test_interval_with_until
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=DAILY;INTERVAL=10;UNTIL=19971012T090000Z")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970912T090000"), #Sep 12
      DateTime.parse("US-Eastern:19970922T090000"), #Sep 22
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
      DateTime.parse("US-Eastern:19971012T090000"), #Oct 12
    ]
    
    #LJK: note this test takes a LONG time to run when I use the normal end date;
    #I need to add something somewhere to optimize this or call out that it's too large a range
    results = rrule.get_recurrence_set(dstart, DateTime.parse("US-Eastern:19980301T090000"))
    
    assert_equal(expected, results)
  end

  # "Every day in January, for 3 years" (first example, yearly byday)
  def test_rfc_2445_example_5_a
    dstart = DateTime.parse("US-Eastern:19980101T090000")
    rrule = RecurrenceRule.new("FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA")
    
    expected = []
    expected += RecurrenceRule.get_date_range(DateTime.parse("US-Eastern:19980101T090000"), DateTime.parse("US-Eastern:19980131T090000"))
    expected += RecurrenceRule.get_date_range(DateTime.parse("US-Eastern:19990101T090000"), DateTime.parse("US-Eastern:19990131T090000"))
    expected += RecurrenceRule.get_date_range(DateTime.parse("US-Eastern:20000101T090000"), DateTime.parse("US-Eastern:20000131T090000"))
    
    results = rrule.get_recurrence_set(dstart, END_DATE)
    
    assert_equal(expected, results)
  end

  # "Every day in January, for 3 years" (second example, daily bymonth)
  def test_rfc_2445_example_5_b
    dstart = DateTime.parse("US-Eastern:19980101T090000")
    rrule = RecurrenceRule.new("FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1")
    
    expected = []
    expected += RecurrenceRule.get_date_range(DateTime.parse("US-Eastern:19980101T090000"), DateTime.parse("US-Eastern:19980131T090000"))
    expected += RecurrenceRule.get_date_range(DateTime.parse("US-Eastern:19990101T090000"), DateTime.parse("US-Eastern:19990131T090000"))
    expected += RecurrenceRule.get_date_range(DateTime.parse("US-Eastern:20000101T090000"), DateTime.parse("US-Eastern:20000131T090000"))
    
    results = rrule.get_recurrence_set(dstart, END_DATE)
    
    assert_equal(expected, results)
  end

  # "Weekly for 10 occurrences"
  def test_rfc_2445_example_6
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;COUNT=10")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971007T090000"), #Oct 7
      DateTime.parse("US-Eastern:19971014T090000"), #Oct 14
      DateTime.parse("US-Eastern:19971021T090000"), #Oct 21
      DateTime.parse("US-Eastern:19971028T090000"), #Oct 28
      DateTime.parse("US-Eastern:19971104T090000"), #Nov 4
    ]
    results = rrule.get_recurrence_set(dstart, END_DATE)
    
    assert_equal(expected, results)
  end

  # "Weekly until December 24th, 1997"
  def test_rfc_2445_example_7
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;UNTIL=19971224T000000Z")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971007T090000"), #Oct 7
      DateTime.parse("US-Eastern:19971014T090000"), #Oct 14
      DateTime.parse("US-Eastern:19971021T090000"), #Oct 21
      DateTime.parse("US-Eastern:19971028T090000"), #Oct 28
      DateTime.parse("US-Eastern:19971104T090000"), #Nov 4
      DateTime.parse("US-Eastern:19971111T090000"), #Nov 11
      DateTime.parse("US-Eastern:19971118T090000"), #Nov 18
      DateTime.parse("US-Eastern:19971125T090000"), #Nov 25
      DateTime.parse("US-Eastern:19971202T090000"), #Dec 2
      DateTime.parse("US-Eastern:19971209T090000"), #Dec 9
      DateTime.parse("US-Eastern:19971216T090000"), #Dec 16
      DateTime.parse("US-Eastern:19971223T090000"), #Dec 23
    ]
    results = rrule.get_recurrence_set(dstart, END_DATE)
    
    assert_equal(expected, results)
  end
  
  # "Weekly on Tuesday and Thursday for 5 weeks (first example, using until)"
  def test_rfc_2445_example_9_a
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970904T090000"), #Sep 4
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970911T090000"), #Sep 11
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970918T090000"), #Sep 18
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970925T090000"), #Sep 25
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
    ]
    results = rrule.get_recurrence_set(dstart, END_DATE)
    
    assert_equal(expected, results)
  end  

  # "Weekly on Tuesday and Thursday for 5 weeks (second example, using count)"
  def test_rfc_2445_example_9_b
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970904T090000"), #Sep 4
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970911T090000"), #Sep 11
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970918T090000"), #Sep 18
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970925T090000"), #Sep 25
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
    ]
    results = rrule.get_recurrence_set(dstart, END_DATE)
    
    assert_equal(expected, results)
  end  

  def debug(expected, results)
    puts "expected:"
    expected.each {|date| puts date}
    puts "results:"
    results.each {|date| puts date}
  end
end
