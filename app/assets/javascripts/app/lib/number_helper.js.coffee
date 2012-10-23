class App.Lib.NumberHelper

  # Formats the bytes in +number+ into a more understandable
  # representation e.g. (giving 1500 yields 1.5 KB).
  @numberToHumanSize: (bytes) ->
    return '' if typeof(bytes) != 'number'
    if (bytes >= 1000000000)
      return (bytes / 1000000000).toFixed(2) + ' GB'
    if (bytes >= 1000000)
      return (bytes / 1000000).toFixed(2) + ' MB'
    return (bytes / 1000).toFixed(2) + ' KB'
