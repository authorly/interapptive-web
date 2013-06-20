class App.Lib.StringHelper

  # Capitalize first character of the passed string.
  #
  #   > App.Lib.StringHelper.capitalize('string')
  #   => 'String'
  #
  #   > App.Lib.StringHelper.capitalize('String')
  #   => 'String'
  @capitalize: (str) ->
    return str.charAt(0).toUpperCase() + str.slice(1)

  # De-capitalize first character of the passed string.
  #
  #   > App.Lib.StringHelper.capitalize('string')
  #   => 'string'
  #
  #   > App.Lib.StringHelper.capitalize('String')
  #   => 'string'
  @decapitalize: (str) ->
    return str.charAt(0).toLowerCase() + str.slice(1)


  @camelize: (str) ->
    str.replace /(?:^|[-_])(\w)/g, (_, c) ->
      if c? then c.toUpperCase() else ''


  @truncate: (str, take = 6, trail_with = '...') ->
    return str if str.length <= take
    str.substr(0, take) + trail_with


  @wordCount: (str) ->
    str = $.trim(str)
    return 0 if str == ''
    str.split(/\s+/).length

