$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'icalendar'

require 'date'

class TestConversions < Test::Unit::TestCase
  include Icalendar

  RESULT = <<EOS
BEGIN:VCALENDAR
VERSION:2.0
CALSCALE:GREGORIAN
PRODID:iCalendar-Ruby
BEGIN:VEVENT
ORGANIZER:mailto:joe@example.com?subject=Ruby
UID:foobar
X-TIME_OF_DAY:012034
CATEGORIES:foo,bar,baz
GEO:46.01;8.57
DESCRIPTION:desc
DTSTART:20060720
DTSTAMP:20060720T174052
SEQ:2
END:VEVENT
END:VCALENDAR
EOS

  def setup
    @cal = Calendar.new
  end

  def test_to_ical_conversions
    @cal.event do 
      # String
      description "desc"

      # Fixnum
      sequence 2

      # Float by way of Geo class
      geo(Geo.new(46.01, 8.57))
      
      # Array
      categories ["foo", "bar"]
      add_category "baz"

      # URI
      organizer(URI::MailTo.build(['joe@example.com', 'subject=Ruby']))
      
      # Date
      start  Date.parse("2006-07-20")

      # DateTime
      timestamp DateTime.parse("2006-07-20T17:40:52+0200")

      # Time
      x_time_of_day Time.at(1234)

      uid "foobar"
    end
       
    assert_equal(RESULT.gsub("\n", "\r\n"), @cal.to_ical)
  end
end
