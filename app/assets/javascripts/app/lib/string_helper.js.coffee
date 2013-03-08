class App.Lib.StringHelper

  @capitalize: (str) ->
    return str.charAt(0).toUpperCase() + str.slice(1)

  @decapitalize: (str) ->
    return str.charAt(0).toLowerCase() + str.slice(1)

  @camelize: (str) ->
    str.replace /(?:^|[-_])(\w)/g, (_, c) ->
      if c? then c.toUpperCase() else ''
