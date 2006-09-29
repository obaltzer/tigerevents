module EventsHelper

  def iCal_date(date)
    return date.strftime("%Y%m%dT%H%M%SZ")
  end

  def gCal_link(event)
    if event.endTime
    return "<a href=\"http://www.google.com/calendar/event?action=TEMPLATE" +
         "&text=#{html_escape(event.title).gsub(",", "%2C")}" +
         "&dates=#{iCal_date(event.startTime)}/#{iCal_date(event.endTime)}" +
         "&details=#{html_escape(event.description).gsub(",", "%2C")}" +
         "&location=#{html_escape(event.location)}" +
         "&trp=false&sprop=&sprop=name:\" target=\"_blank\">Add To gCal</a>"
    else
    return "<a href=\"http://www.google.com/calendar/event?action=TEMPLATE" +
         "&text=#{html_escape(event.title).gsub(",", "%2C")}" +
         "&dates=#{iCal_date(event.startTime)}" +
         "&details=#{html_escape(event.description)}" +
         "&location=#{html_escape(event.location)}" +
         "&trp=false&sprop=&sprop=name:\" target=\"_blank\">Add To gCal</a>"
    
    end
  end
end
