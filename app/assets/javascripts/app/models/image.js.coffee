 # name size url thumbnail_url delete_url delete_type created_at
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


  save: ->
    @deferredSave() # ignores arguments


  widgetChanged: (widget) ->
    if widget instanceof App.Models.HotspotWidget or
       widget instanceof App.Models.SpriteOrientation or
       widget instanceof App.Models.ImageWidget
      @trigger 'invalid'
      @invalid = true


  isInvalid: ->
    @invalid


  setDataUrl: (dataUrl) ->
    @invalid = false
    @set 'data_url', dataUrl


_.extend App.Models.Preview::, App.Mixins.DeferredSave
_.extend App.Models.Preview::, App.Mixins.QueuedSync
