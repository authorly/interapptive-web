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

  url: ->
    @cached_url ||= (new App.Collections.ImagesCollection).url()
    if @isNew() then @cached_url else @cached_url.replace(/\.json$/, "/#{@id}")


  # id, url -> from the server
  # data_url -> from the app
  initialize: ->
    @set 'preview', true
    @on 'change:data_url', => @save()


  src: ->
    @get('data_url') || @get('url')


  # Override save to
  # - prevent `save` being called once to create the record, and then again before
  # the ajax request returns (which would create two records instead of one)
  # - debounce calls to `save` so we don't save too often
  # This does not take into account any parameters. Use `set` to change the
  # attributes, followed by a call to `save` without parameters.
  save: () ->
    if @isNew()
      if !@_firstSave?
        @_firstSave = @_actualSave(success: => @trigger('change:id', @))
      else
        # `@_firstSave` is a deferred; wait until it resolves
        # TODO error handling
        $.when(@_firstSave).done => @_debouncedSave().apply(@)
    else
      @_debouncedSave().apply @


  _debouncedSave: ->
    @deboucedSaveMemoized ||= _.debounce @_actualSave, 500


  _actualSave: (options={}) =>
    Backbone.Model.prototype.save.apply @, {}, options
