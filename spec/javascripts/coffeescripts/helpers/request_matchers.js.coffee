beforeEach ->
  @addMatchers
    toBeGET: ->
      actual = @actual.method
      actual is "GET"

    toBePOST: ->
      actual = @actual.method
      actual is "POST"

    toBePUT: ->
      actual = @actual.method
      actual is "PUT"

    toHaveUrl: (expected) ->
      actual = @actual.url
      @message = ->
        "Expected request to have url " + expected + " but was " + actual

      actual is expected

    toBeAsync: ->
      actual = @actual.async
      actual

