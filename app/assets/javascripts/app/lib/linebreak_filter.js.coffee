##
# Sanitizes a string of any linebreaks/brs/etc.
# Suited for elements using contentEditable (i.e., text widgets)
#
# Source: http://jsfiddle.net/tG9Qa/
#
class App.Lib.LinebreakFilter
  @filter: (div) ->
    _results = []

    for ref in div.contents()
      node = ref
      if node.nodeType is 3
        node.nodeValue = node.nodeValue.replace('\n', '')
        if prev
          node.nodeValue = prev.nodeValue + node.nodeValue
          $(prev).remove()
        _results.push prev = node
      else if node.tagName.toLowerCase() is "br"
        _results.push $(node).remove()
      else
        $(node).css 'display', 'inline'
        @filter $(node)
        _results.push(prev = null)

    _results