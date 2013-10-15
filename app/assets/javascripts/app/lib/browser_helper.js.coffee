class App.Lib.BrowserHelper

  # Detect if this browser can play Ogg/Vorbis audio format. e.g. Firefox
  # Taken from http://diveintohtml5.info/everything.html
  @canPlayVorbis: ->
    a = document.createElement('audio')
    !!(a.canPlayType && a.canPlayType('audio/ogg; codecs="vorbis"').replace(/no/, ''))
