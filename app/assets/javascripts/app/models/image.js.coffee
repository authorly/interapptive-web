class App.Models.Image extends Backbone.Model

  toString: ->
    @get('name')


class App.Collections.ImagesCollection extends Backbone.Collection

  model: App.Models.Image


  initialize: (models, attributes) ->
    super

    @storybook = attributes.storybook


  baseUrl: ->
    "/storybooks/#{@storybook.id}/images"

  url: ->
    @baseUrl() + '.json'


class App.Models.Preview extends App.Models.Image

  SAVE_TIMER: null

  # id, url -> from the server
  # data_url -> from the app
  initialize: (attributes, options) ->
    @storybook = options.storybook

    @set 'preview', true
    @on 'change:data_url', @save, @


  url: ->
    @cachedUrl ||= (new App.Collections.ImagesCollection([], storybook: @storybook)).baseUrl()
    if @isNew() then @cachedUrl else @cachedUrl + "/#{@id}"


  src: ->
    @get('data_url') || @get('url')


  # Override save to
  # - prevent `save` being called once to create the record, and then again before
  # the ajax request returns (which would create two records instead of one)
  # - debounce calls to `save` so we don't save too often
  # This does not take into account any parameters. Use `set` to change the
  # attributes, followed by a call to `save` without parameters.
  save: ->
    if @isNew() and !@_duringFirstSave
        @_duringFirstSave = true
        @_actualSave()
    else
      window.clearTimeout @SAVE_TIMER
      @SAVE_TIMER = window.setTimeout(@_actualSave, 500)


  _actualSave: =>
    Backbone.Model.prototype.save.apply @
