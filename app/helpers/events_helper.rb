module EventsHelper

  def gCal_link(event)
    link  = "<a href=\"http://www.google.com/calendar/event?action=TEMPLATE"
    link += "&text=#{url_encode(event.title)}"
    if event.endTime
      link += "&dates=#{event.startTime.to_formatted_s(:iCal_short)}/#{event.endTime.to_formatted_s(:iCal_short)}"
    else
      link += "&dates=#{event.startTime.to_formatted_s(:iCal_short)}"
    end
    link += "&details=#{url_encode(event.description)}"
    link += "&location=#{url_encode(event.location)}"
    link += "&trp=false"
    link += "&sprop=#{url_encode(event.url)}"
    link += "&sprop=name:\" target=\"_blank\">Add To Google Calendar</a>"
    return link
  end
end
