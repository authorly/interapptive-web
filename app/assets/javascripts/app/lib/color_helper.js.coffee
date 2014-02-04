class App.Lib.ColorHelper

  # Formats the bytes in +number+ into a more understandable
  # representation e.g. (giving 1500 yields 1.5 KB).
  @rgbToHex: (r, g, b) ->
    @_toHex(r) + @_toHex(g) + @_toHex(b)


  @_toHex: (n) ->
    n = parseInt(n, 10)
    return '00' if isNaN(n)
    n = Math.max(0, Math.min(n, 255))
    "0123456789abcdef".charAt((n - n % 16) / 16) +
      "0123456789abcdef".charAt(n % 16)
