class App.Lib.DateTimeHelper

  # Formats a date time string in human readable format.
  @timeToHuman: (dateString) ->
    d = new Date(dateString)

    # TODO: WA: Extend this helper to support more formats.
    # Take inspiration from
    # http://api.rubyonrails.org/classes/DateTime.html#method-i-to_default_s
    #
    # format ?= 'default'
    format = 'default'

    year   = d.getFullYear()

    month  = d.getMonth()
    month_padding = ''
    if month < 10
      month_padding = '0'

    date    = d.getDate()
    date_padding = ''
    if date < 10
      date_padding = '0'

    hour   = d.getHours()
    if hour > 12
      meridiem = 'pm'
      hour = hour - 12
    else
      meridiem = 'am'
    hour_padding = ''
    if hour < 10
      hour_padding = '0'

    minutes = d.getMinutes()
    minutes_padding = ''
    if minutes < 10
      minutes_padding = '0'

    if format == 'default'
      "#{year}-#{month_padding}#{month}-#{date_padding}#{date} #{hour_padding}#{hour}:#{minutes_padding}#{minutes}#{meridiem}"
    else
      d.toString()

  @secondsToDuration: (seconds) ->
    hours = seconds / 3600
    seconds %= 3600
    minutes = seconds / 60
    seconds %= 60
    if hours < 1 then hours = 0
    if hours < 10 then hours_padding = '0' else hours_padding = ''

    if minutes < 1 then minutes = 0
    if minutes < 10 then minutes_padding = '0' else minutes_padding = ''

    if seconds < 1 then seconds = 0
    if seconds < 10 then seconds_padding = '0' else seconds_padding = ''

    "#{hours_padding}#{hours}:#{minutes_padding}#{minutes}:#{seconds_padding}#{seconds}"
