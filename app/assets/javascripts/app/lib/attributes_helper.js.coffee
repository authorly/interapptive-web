class App.Lib.AttributesHelper
  @filterByPrefix: (attributes, prefix) ->
    filtered = {}
    _.each attributes, (value, name) ->
      if name.indexOf(prefix) == 0
        filtered[name.substr(prefix.length)] = value

    filtered
