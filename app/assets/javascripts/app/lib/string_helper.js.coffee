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


  @truncate: (str, take = 6, trail_with = '...') ->
    return str if str.length <= take
    str.substr(0, take) + trail_with
